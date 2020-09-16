import configparser
import datetime
import logging
import io
import time
import xml.etree.ElementTree as et
from contextlib import contextmanager

import requests

from dim import db
from dim.models import RegistrarAccount, RegistrarAction, Zone, ZoneKey
from dim.models.history import record_history


proxies = {}


@contextmanager
def transaction_scope():
    """Provide a transactional scope around a series of operations."""
    try:
        yield
    except:
        db.session.rollback()
        raise
    finally:
        db.session.close()


def make_request(request, account, ctid=''):
    request = '''<?xml version="1.0" encoding="utf-8"?>
    <request>
      <auth>
        <user>%s</user>
        <password>%s</password>
        <context>%s</context>
      </auth>
      <language>en</language>
    <task><ctid>%s</ctid>''' % (account['username'], account['password'], account['subaccount'],
                                ctid) + request + '</task></request>'

    r = requests.post(account['url'],
                      data=request,
                      proxies=proxies,
                      headers={'Content-Type': 'application/xml',
                               'charset': 'utf-8'})
    if r.status_code != 200:
        raise Exception('status code: %d' % r.status_code)
    return r.text


def replace_keys(domain, keys):
    key_template = '''
        <dnssec>
          <flags>257</flags>
          <protocol>3</protocol>
          <algorithm>8</algorithm>
          <publickey>%s</publickey>
        </dnssec>'''
    key_info = '\n'.join([key_template % key for key in keys])
    return '''<code>0102</code>
      <domain>
        <name>%s</name>
        %s
        <extension>
          <mode>1</mode>
        </extension>
      </domain>''' % (domain, key_info)


def pollinfo():
    return '''<code>0905</code>'''


def ack(message_id):
    return '''<code>0906</code><message><id>%s</id></message>''' % message_id


def got_notification(e):
    try:
        return e.find('./result/status/code').text == 'N0102'
    except:
        return False


def get_pretty_error_message(reply):
    try:
        e = et.fromstring(reply)
    except:
        return reply
    try:
        return get_error_from_message(e)
    except:
        try:
            return get_request_error(e)
        except:
            return reply


def get_request_error(e):
    if e.find('./result/status/type').text != 'error':
        return ''
    errors = [e.find('./result/status/text').text]
    for msg in e.findall('./result/msg'):
        errors.append(msg.find('text').text)
    return '\n'.join(errors)


def get_error_from_message(e):
    if e.find('./result/data/message/job/status/type').text != 'error':
        return ''
    errors = [e.find('./result/data/message/job/status/text').text]
    for msg in e.findall('./result/data/message/job/nic_response'):
        errors.append(msg.text)
    return '\n'.join(errors)


def is_success_message(e):
    return e.find('./result/data/message/job/status/type').text == 'success'


def queued(e):
    return int(e.find('./result/data/summary').text)


def get_action_keys(action):
    return ZoneKey.query.filter(ZoneKey.registrar_action == action).all()


def get_account_info(account):
    '''Get info from a RegistrarAccount and save it in a dict'''
    return dict(id=account.id,
                name=account.name,
                url=account.url,
                username=account.username,
                password=account.password,
                subaccount=account.subaccount)


def unlink_action_keys(action_keys):
    for key in action_keys:
        key.registrar_action = None


def handle_pending():
    while True:
        with transaction_scope():
            action = RegistrarAction.query.filter_by(status='pending').first()
            if action is None:
                break
            try:
                action.started = datetime.datetime.utcnow()
                reply = make_request(replace_keys(action.zone.name,
                                                  [key.pubkey for key in action.zone.keys if
                                                   key.registrar_action == action]),
                                     get_account_info(action.zone.registrar_account), action.id)
                if got_notification(et.fromstring(reply)):
                    logging.info('Request domain update for %s with registrar-account %s accepted' %
                                 (action.zone.display_name, action.zone.registrar_account.name))
                    action.status = 'running'
                else:
                    logging.info('Request domain update for %s with registrar-account %s failed' %
                                 (action.zone.display_name, action.zone.registrar_account.name))
                    action.status = 'failed'
                    action.error = reply
                    action.completed = datetime.datetime.utcnow()
                    unlink_action_keys(get_action_keys(action))
                db.session.commit()
            except Exception:
                logging.exception('Error requesting domain update for %s with registrar-account %s' %
                                  (action.zone.display_name, action.zone.registrar_account.name))


def poll_queue(account):
    with transaction_scope():
        running = RegistrarAction.query.filter_by(status='running').join(Zone).join(RegistrarAccount)\
            .filter(RegistrarAccount.id == account['id']).count()
        if running == 0:
            return
    while True:
        poll_info = make_request(pollinfo(), account)
        pi = et.fromstring(poll_info)
        queued_messages = queued(pi)
        if not queued_messages:
            break
        logging.debug('registrar-account %s has %d messages queued' %
                      (account['name'], queued_messages))
        msg_id = pi.find('./result/data/message/id')
        ctid = pi.find('./result/data/message/job/ctid')
        if ctid is not None:
            with transaction_scope():
                action = RegistrarAction.query.filter_by(id=int(ctid.text)).first()
                if action is None:
                    logging.warn('Ignoring registrar-account %s reply for action with id %s' %
                                 (account['name'], ctid.text))
                else:
                    action.completed = datetime.datetime.utcnow()
                    action_keys = list(get_action_keys(action))
                    if is_success_message(pi):
                        action.status = 'done'
                        action.zone.update_registrar_keys(action_keys)
                        if action_keys:
                            record_history(action.zone.registrar_account, action='published',
                                           zone=action.zone.display_name,
                                           action_info=(', '.join([act.label for act in action_keys]) +
                                                        ' published ' +
                                                        ', '.join([act.ds(2) for act in action_keys])))
                        else:
                            record_history(action.zone.registrar_account, action='published',
                                           zone=action.zone.display_name,
                                           action_info='unpublished all DS records')
                        logging.info('Domain update for %s successful with registrar-account %s' %
                                     (action.zone.display_name, action.zone.registrar_account.name))
                    else:
                        action.error = poll_info
                        action.status = 'failed'
                        logging.info('Domain update for %s failed with registrar-account %s' %
                                     (action.zone.display_name, action.zone.registrar_account.name))
                    unlink_action_keys(action_keys)
                    db.session.commit()
        if msg_id is not None:
            r = make_request(ack(msg_id.text), account)
            if not queued(et.fromstring(r)):
                break


def discard_old_operations():
    ''' Discard operations running for more than 1 day by setting their status to 'unknown'.
    From the autodns3 API docs: "Polling allows you to connect directly to our system and poll messages in XML format.
    If the messages are not polled within 24 hours, they are sent in XML format by email."
    '''
    with transaction_scope():
        actions = RegistrarAction.query.filter_by(status='running') \
            .filter(RegistrarAction.started < datetime.datetime.utcnow() - datetime.timedelta(days=1)).all()
        for action in actions:
            action_keys = list(get_action_keys(action))
            unlink_action_keys(action_keys)
            action.status = 'unknown'
            logging.warn('Marked action on zone %s started on %s as unknown' %
                         (action.zone.display_name, action.started))
        db.session.commit()


def read_config():
    global proxies
    try:
        CONFIG_FILE = '/etc/dim/dim-autodns3-plugin.cfg'
        parser = configparser.ConfigParser()
        with open(CONFIG_FILE) as stream:
            stream = io.StringIO("[root]\n" + stream.read())
            parser.readfp(stream)
            proxy = parser.get('root', 'proxy')
            if proxy:
                proxies = {'http': proxy, 'https': proxy}
                logging.debug('Running autodns3 with proxy %s' % proxy)
    except Exception:
        logging.exception('Error reading configuration file %s' % CONFIG_FILE)
        raise


def run():
    logging.getLogger("requests").setLevel(logging.WARNING)
    read_config()
    while True:
        handle_pending()
        discard_old_operations()
        accounts = []
        with transaction_scope():
            for account in RegistrarAccount.query.all():
                accounts.append(get_account_info(account))
        for account in accounts:
            try:
                poll_queue(account)
            except Exception:
                logging.exception('Error polling registrar-account %s' % account.name)
        time.sleep(5)
