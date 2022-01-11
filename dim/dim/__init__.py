import logging.handlers
import os
import socket
import sys
from datetime import datetime, timedelta

import flask_sqlalchemy
import sqlalchemy.orm
import sqlalchemy.pool
from flask import Flask, g
from flask.sessions import SecureCookieSessionInterface
from sqlalchemy import event, String
from sqlalchemy.ext.declarative import declared_attr, declarative_base
from sqlalchemy.orm import ColumnProperty

from .errors import InvalidParameterError
from .ipaddr import IP
from . import version

__all__ = ['db', 'create_app', 'script_app']
__version__ = version.VERSION

class TransactionLoggingFormatter(logging.Formatter):
    def format(self, record):
        if g and hasattr(g, 'tid'):
            record.tid = ' ' + g.tid
        else:
            record.tid = ''
        return logging.Formatter.format(self, record)


def create_app(db_mode=None, testing=False):
    app = Flask(__name__)

    app.config.from_pyfile('defaults.py')
    app.config.from_pyfile( os.getenv('DIM_CONFIG','/etc/dim/dim.cfg'), silent=True)
    app.config.from_pyfile('../etc/dim.cfg', silent=True)
    os.environ['REQUESTS_CA_BUNDLE'] = app.config['REQUESTS_CA_BUNDLE']
    app.testing = testing
    configure_logging(app)
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    if db_mode:
        app.config['SQLALCHEMY_DATABASE_URI'] = app.config['SQLALCHEMY_DATABASE_URI_' + db_mode]

    if testing:
        app.config['LAYER3DOMAIN_WHITELIST'] = app.config.get('LAYER3DOMAIN_WHITELIST', ['10.0.0.0/8', '176.16.0.0/12', '192.168.0.0/16'])

    if 'LAYER3DOMAIN_WHITELIST' not in app.config:
        logging.error('LAYER3DOMAIN_WHITELIST not set')
        sys.exit(1)
    try:
        app.config['LAYER3DOMAIN_WHITELIST'] = [IP(ip_str) for ip_str in app.config['LAYER3DOMAIN_WHITELIST']]
    except:
        logging.error('Error parsing LAYER3DOMAIN_WHITELIST', exc_info=1)
        sys.exit(1)
    db.init_app(app)

    from .jsonrpc import jsonrpc
    app.register_blueprint(jsonrpc)
    return app


def script_app(*args, **kwargs):
    app = create_app(*args, **kwargs)
    app.test_request_context().push()
    return app


def syslog_workaround():
    # Workaround for http://bugs.python.org/issue14452
    if sys.version_info < (2, 7):
        # code taken from python 2.7 and modified to send the message in ~1000 bytes chunks
        def emit_once(self, record, msg):
            prio = '<%d>' % self.encodePriority(self.facility,
                                                self.mapPriority(record.levelname))
            msg = prio + msg + '\000'
            try:
                if self.unixsocket:
                    try:
                        self.socket.send(msg)
                    except socket.error:
                        self._connect_unixsocket(self.address)
                        self.socket.send(msg)
                elif self.socktype == socket.SOCK_DGRAM:
                    self.socket.sendto(msg, self.address)
                else:
                    self.socket.sendall(msg)
            except (KeyboardInterrupt, SystemExit):
                raise
            except:
                self.handleError(record)

        def fixed_sysloghandler_emit(self, record):
            # Message is a string. Convert to bytes as required by RFC 5424
            msg_full = self.format(record)
            if type(msg_full) is str:
                msg_full = msg_full.encode('utf-8')
            CHUNK_SIZE = 980
            i = 0
            while i < len(msg_full):
                end = i + CHUNK_SIZE
                emit_once(self, record, msg_full[i:end])
                i = end
        logging.handlers.SysLogHandler.emit = fixed_sysloghandler_emit


def configure_logging(app):
    syslog_workaround()
    if app.testing:
        logging.basicConfig(level=app.config['LOGGING_LEVEL'], format='%(levelname)-5s:%(message)s')
        if app.config['SQLALCHEMY_LOG']:
            logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)
        return
    root_logger = logging.getLogger()
    root_logger.setLevel(app.config['LOGGING_LEVEL'])
    for h in root_logger.handlers:
        root_logger.removeHandler(h)

    formatter = TransactionLoggingFormatter('%(levelname)-5s%(tid)s - %(message)s')
    handler = app.config.get('LOGGING_HANDLER', logging.StreamHandler())
    handler.setFormatter(formatter)
    root_logger.addHandler(handler)

    logging.getLogger('werkzeug').setLevel(logging.WARNING)
    if app.config['SQLALCHEMY_LOG']:
        logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)


class Model(object):
    query_class = sqlalchemy.orm.Query
    default_table_kwargs = {'mysql_engine': 'InnoDB', 'mysql_charset': 'utf8'}

    def __repr__(self):
        def reprs():
            for name in list(self.__mapper__.c.keys()):
                yield name, repr(getattr(self, name))

        def format(seq):
            for key, value in seq:
                yield '%s=%s' % (key, value)

        args = '(%s)' % ', '.join(format(reprs()))
        classy = type(self).__name__
        return classy + args

    @declared_attr
    def __table_args__(cls):
        return getattr(cls, '__table_constraints__', ()) + (Model.default_table_kwargs, )

    @declared_attr
    def __tablename__(cls):
        return cls.__name__.lower()


db = flask_sqlalchemy.SQLAlchemy()
db.Model = declarative_base(cls=Model)
db.Model.query = flask_sqlalchemy._QueryProperty(db)


# set timezone for mysql
@event.listens_for(sqlalchemy.pool.Pool, "connect")
def set_timezone(dbapi_con, con_record):
    cursor = dbapi_con.cursor()
    cursor.execute("SET time_zone = '+0:00'")
    cursor.close()


# We need to check the string lengths because MySQL silently truncates string
# values which are too long
def check_string_length(cls, key, inst):
    prop = inst.prop
    # Only interested in simple columns, not relations
    if isinstance(prop, ColumnProperty) and len(prop.columns) == 1:
        col = prop.columns[0]
        # if we have string column with a length, install a length validator
        if isinstance(col.type, String) and col.type.length:
            max_length = col.type.length

            def set_(instance, value, oldvalue, initiator):
                if isinstance(value, str) and len(value) > max_length:
                    raise InvalidParameterError("Field %s exceeds maximum length %d" % (col.name, max_length))
            event.listen(inst, 'set', set_)


event.listen(db.Model, 'attribute_instrument', check_string_length)
