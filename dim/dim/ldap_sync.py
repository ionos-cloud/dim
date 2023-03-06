

import logging
import sys

import ldap3
import ssl
from flask import current_app as app

from dim import db
from dim.models import Group, User, GroupMembership, Department
from dim.transaction import time_function, transaction
from typing import List


class LDAP(object):
    def __init__(self):
        server_kwargs = {}
        tls_kwargs = app.config.get_namespace('LDAP_SERVER_TLS_')
        if app.config['LDAP_SERVER'].startswith('ldaps'):
            if 'validate' in tls_kwargs.keys() and not tls_kwargs['validate']:
                tls_kwargs['validate'] = ssl.CERT_NONE
            else:
                tls_kwargs['validate'] = ssl.CERT_REQUIRED
            server_kwargs['tls'] = ldap3.Tls(**tls_kwargs)

        ldap_server = ldap3.Server(app.config['LDAP_SERVER'], **server_kwargs)
        conn = ldap3.Connection(ldap_server, read_only=True, client_strategy=ldap3.SAFE_SYNC)
        try:
            (status, result, response, request) = conn.bind()
        except ldap3.core.exceptions.LDAPExceptionError as e:
            logging.exception('Error connecting to ldap server %s: %s', ldap_server, e)
            raise
        if not status:
            logging.exception('Error connecting to ldap server %s: %s', ldap_server, result)
            raise
        self.conn = conn

    def query(self, base: str, search_filter: str, attributes: List[str] = None):
        try:
            status, result, response, _ = self.conn.search(base, search_filter, attributes=attributes, search_scope=ldap3.LEVEL)
            return response
        except:
            logging.exception('Error in LDAP query %s %s', base, search_filter)
            raise

    def users(self, search_filter: str, attributes: List[str] = ['o', 'cn', 'uid', 'departmentNumber']):
        '''Return the set of usernames matching the ldap query.'''
        def fix_int(s): return int(s) if s is not None else s
        return [User(username=u['attributes']['o'][0],
                     ldap_cn=u['attributes']['cn'][0],
                     ldap_uid=fix_int(u['attributes']['uid'][0]),
                     department_number=fix_int(u['attributes']['departmentNumber'][0]),
                     register=False)
                for u in self.query(app.config['LDAP_USER_BASE'], search_filter, attributes)]

    def departments(self, search_filter: str = '(objectClass=organizationalUnit)', attributes: List[str] = ['ou', 'cn']):
        '''Return the list of departments'''
        res = self.query(app.config['LDAP_DEPARTMENT_BASE'], search_filter, attributes)
        if not res:
            return []
        else:
            return [Department(department_number=int(dept['attributes']['ou'][0]),
                               name=dept['attributes']['cn'][0])
                    for dept in res]


def sync_departments(ldap: LDAP, deletion_threshold: int = -1, ignore_deletion_threshold: bool = False):
    '''Update the department table'''
    db_departments = Department.query.all()
    ldap_departments = dict((dep.department_number, dep) for dep in ldap.departments())
    # handle renamed or deleted departments
    for ddep in db_departments:
        ldep = ldap_departments.get(ddep.department_number)
        if ldep:
            if ddep.name != ldep.name:
                logging.info('Renaming department %s to %s' % (ddep.name, ldep.name))
                ddep.name = ldep.name
            del ldap_departments[ddep.department_number]
        else:
            logging.info('Deleting department %s' % ddep.name)
            db.session.delete(ddep)
    if not ignore_deletion_threshold:
        check_deletion_threshold(Department, deletion_threshold)
    # handle new departments
    for ldep in list(ldap_departments.values()):
        logging.info('Creating department %s' % ldep.name)
        db.session.add(ldep)


def log_stdout(message: str):
    logging.info(message)
    print(message)


def check_deletion_threshold(instance_type: type, threshold: int = -1):
    if threshold >= 0:
        deleted_elements = [e for e in db.session.deleted if isinstance(e, instance_type)]
        if len(deleted_elements) > threshold:
            msg = 'Number of %s deletions (%s) above threshold (%s), aborting sync.' % (instance_type.__name__, len(deleted_elements), threshold)
            logging.exception(msg)
            raise Exception(msg)


def sync_users(ldap: LDAP, deletion_threshold: int = -1, ignore_deletion_threshold: bool = False):
    '''Update the user table ldap_cn, ldap_uid and department_number fields'''
    db_users = User.query.all()
    ldap_users = dict((u.username, u)
                      for u in ldap.users('(|%s)' % ''.join('(o=%s)' % u.username for u in db_users)))
    for db_user in db_users:
        ldap_user = ldap_users.get(db_user.username)
        if ldap_user:
            if db_user.ldap_cn != ldap_user.ldap_cn:
                logging.info('User %s changed cn from %s to %s' %
                             (db_user.username,
                              db_user.ldap_cn,
                              ldap_user.ldap_cn))
                db_user.ldap_cn = ldap_user.ldap_cn
            if db_user.department_number != ldap_user.department_number:
                logging.info('User %s moved from department_number %s to %s' %
                             (db_user.username,
                              db_user.department_number,
                              ldap_user.department_number))
                db_user.department_number = ldap_user.department_number
            if db_user.ldap_uid != ldap_user.ldap_uid:
                logging.info('User %s changed uid from %s to %s' %
                             (db_user.username,
                              db_user.ldap_uid,
                              ldap_user.ldap_uid))
                db_user.ldap_uid = ldap_user.ldap_uid
        elif db_user.ldap_uid:
            log_stdout('Deleting user %s' % db_user.username)
            db.session.delete(db_user)
    if not ignore_deletion_threshold:
        check_deletion_threshold(User, deletion_threshold)


@time_function
@transaction
def ldap_sync(ignore_deletion_threshold: bool = False, cleanup_department_groups: bool = False):
    '''Update Users, Group, and Departments from LDAP'''
    ldap = LDAP()
    deletion_thresholds = app.config.get_namespace('LDAP_SYNC_DELETION_THRESHOLD_')

    if sys.stdout.isatty():
        logging.getLogger().addHandler(logging.StreamHandler(sys.stderr))

    sync_departments(ldap, int(deletion_thresholds.get('departments', -1)), ignore_deletion_threshold)
    sync_users(ldap, int(deletion_thresholds.get('users', -1)), ignore_deletion_threshold)

    # Synchronize group members
    ldap_users = {}  # map department_number to list of usernames
    for group in Group.query.filter(Group.department_number != None).all():  # noqa
        search_results = ldap.departments('(ou=%s)' % group.department_number)
        if len(search_results) == 0:
            group.department_number = None
            log_stdout('Department %s %s was deleted and had the following members from LDAP: %s' % (
                group.department_number,
                group.name,
                ' '.join(gm.user.username for gm in GroupMembership.query
                         .filter(GroupMembership.from_ldap)
                         .filter(GroupMembership.group == group).all())))
        else:
            dept = search_results[0]
            if dept.name != group.name:
                new_name = dept.name
                if Group.query.filter(Group.name == new_name).count():
                    # DIM-209 append id to department name to generate an unique user group name
                    new_name += '_%s' % dept.department_number
                logging.info('Renaming group %s to %s' % (group.name, new_name))
                group.name = new_name
            ldap_users[group.department_number] = \
                [u.username for u in ldap.users('(departmentNumber=%s)' % dept.department_number)]
    # Remove all users added by a ldap query that are no longer present in the group
    for membership in GroupMembership.query.filter(GroupMembership.from_ldap).all():  # noqa
        if membership.group.department_number is None or \
           membership.user.username not in ldap_users[membership.group.department_number]:
            logging.info('User %s was removed from group %s' %
                         (membership.user.username, membership.group.name))
            membership.group.remove_user(membership.user)
    # Remove users in department user-groups, that have not been added via ldap
    if cleanup_department_groups:
        for membership in GroupMembership.query.filter(GroupMembership.from_ldap == False).filter(Group.department_number != None).filter(GroupMembership.usergroup_id==Group.id).all():
            if membership.user.username not in ldap_users[membership.group.department_number]:
                logging.info(f'User {membership.user.username} was removed from department group {membership.group.name} ({membership.group.department_number}) as the membership was not from LDAP')
                membership.group.remove_user(membership.user)

    # Add new users to groups
    for group in Group.query.filter(Group.department_number != None).all():  # noqa
        group_users = set([u.username for u in group.users])
        for username in [u for u in ldap_users[group.department_number] if u not in group_users]:
            user = User.query.filter_by(username=username).first()
            if user is None:
                ldap_search = ldap.users('(o=%s)' % username)
                if ldap_search:
                    lu = ldap_search[0]
                    user = User(username=username,
                                ldap_uid=lu.ldap_uid,
                                ldap_cn=lu.ldap_cn,
                                department_number=lu.department_number)
                    db.session.add(user)
                    db.session.add(GroupMembership(user=user, group=group, from_ldap=True))
                    group_users.add(username)
                    logging.info('User %s was created and added to group %s', username, group.name)
            else:
                logging.info('User %s was added to group %s', username, group.name)
                db.session.add(GroupMembership(user=user, group=group, from_ldap=True))
                group_users.add(username)
