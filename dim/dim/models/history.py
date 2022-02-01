import datetime
import logging
from collections import namedtuple

import sqlalchemy.sql.expression as sql_expression
from sqlalchemy.dialects.mysql import TIMESTAMP
from sqlalchemy import select, event, desc, Column, Index, Integer, Numeric, BigInteger, String
from sqlalchemy.orm import mapper
from sqlalchemy.orm.attributes import NO_VALUE
from sqlalchemy.orm.properties import ColumnProperty
from sqlalchemy.sql.expression import literal, union_all

from dim.ipaddr import IP
from dim.models import (db, get_session_username, get_session_tool,
                        get_session_ip_address, get_session_ip_version, Pool, Ipblock, Zone, ZoneView,
                        RR, Output, ZoneGroup, Group, GroupRight, GroupMembership, RegistrarAccount, ZoneKey,
                        Layer3Domain)


AttrChange = namedtuple('AttrChange', ['name', 'new_value', 'old_value'])


# Register history events
@event.listens_for(mapper, 'after_insert')
def insert_listener(mapper, connection, target):
    # Hack for group membership history
    # (can't use collection events for backref or associationproxy)
    if type(target) == GroupMembership:
        make_history(target.group, 'added', collection_item=target.user)
        return
    action = 'created'
    if type(target) == GroupRight:
        action = 'granted'
    if hasattr(target, '_changed_attrs'):
        del target._changed_attrs
    make_history(target, action)


@event.listens_for(mapper, 'before_delete')
def delete_listener(mapper, connection, target):
    # Hack for group membership history
    if type(target) == GroupMembership:
        try:
            make_history(Group.query.filter_by(id=target.usergroup_id).one(), 'removed', collection_item=target.user)
        except:
            logging.exception('Error logging removal of user %s from group %s', target.user, target.group)
        return
    action = 'deleted'
    if type(target) == GroupRight:
        action = 'revoked'
    make_history(target, action)


def collection_listener(action):
    def _collection_listener(target, value, initiator):
        make_history(target, action, collection_item=value)
    return _collection_listener


for collection in [ZoneGroup.views, Output.groups]:
    event.listen(collection, 'append', collection_listener('added'))
    event.listen(collection, 'remove', collection_listener('removed'))


@event.listens_for(mapper, 'after_update')
def update_listener(mapper, connection, target):
    if hasattr(target, '_changed_attrs'):
        changes = target._changed_attrs
        for change in list(changes.values()):
            if change.name == 'name':
                make_history(target, 'renamed', {'name': change.old_value}, changed_attr=change)
            else:
                make_history(target, 'set_attr', changed_attr=change)
        del target._changed_attrs


def setattr_listener(target, value, oldvalue, initiator):
    if not hasattr(target, '_changed_attrs'):
        target._changed_attrs = {}
    if oldvalue == NO_VALUE:
        return
    target._changed_attrs[initiator.key] = AttrChange(initiator.key, value, oldvalue)


def generate_history_table(klass, extra_history_columns, class_attributes, suppress_events=None, fillers=None, indexes=None):
    '''
    Creates a history table.
    *klass* The class to be historized.
    *extra_history_columns* List of columns that will be part of the table.
    *class_attributes* List of columns and relationships of *klass*.
    A listener for the 'set' event will be registered for elements in the list unless they are also in the *suppress_events* list.
    For those that are columns, a column will be created in the history table with the same name and type.
    *suppress_events* List of column attributes which won't be registered to the 'set' event.
    *fillers* Dictionary {column_name: filler}. Useful for columns created from *class_attributes*.
    *indexes* List of indexes to be used for the table.
    '''
    def column_filler(column_name):
        return lambda obj, **kwargs: getattr(obj, column_name, None)
    columns = [Column('id', BigInteger, primary_key=True, nullable=False),
               Column('timestamp', TIMESTAMP(fsp=6), index=True, nullable=False,
                      default=datetime.datetime.utcnow, server_default='1970-01-02 00:00:01'),
               Column('user', String(128), nullable=False, index=True, default=get_session_username),
               Column('tool', String(64), nullable=True, default=get_session_tool),
               Column('call_ip_version', Integer, nullable=True, default=get_session_ip_version),
               Column('call_ip_address', Numeric(precision=40, scale=0), nullable=True, default=get_session_ip_address),
               Column('action', String(32), nullable=False)]
    for class_attr in class_attributes:
        listen = True
        if type(class_attr.property) == ColumnProperty:
            filler = column_filler(class_attr.name)
            if fillers is not None and class_attr.name in fillers:
                filler = fillers[class_attr.name]
            columns.append(Column(class_attr.name, class_attr.type, info={'filler': filler}))
            if suppress_events is not None and (class_attr.name in [attr.name for attr in suppress_events]):
                listen = False
        if listen:
            event.listen(class_attr, 'set', setattr_listener)
    for column in extra_history_columns:
        columns.append(column)
        if 'filler' not in column.info:
            column.info['filler'] = column_filler(column.name)
    if indexes is not None:
        columns += indexes
    klass.history_table = db.Table('history_' + klass.__tablename__, *columns, **db.Model.default_table_kwargs)


def format(value):
    if value is None:
        return None
    if hasattr(value, 'display_name'):
        return value.display_name
    return value


def format_ip(value, version, prefix=None):
    return IP(int(value), version=version, prefix=prefix).label() if value else None


# fillers used with history columns
def group_filler(obj, **kwargs):
    try:
        return Group.query.filter_by(id=obj.usergroup_id).one().name
    except:
        return None


def right_filler(obj, **kwargs):
    try:
        return obj.accessright.access
    except:
        return None


def object_filler(obj, **kwargs):
    def object_str(accessright):
        if accessright.object_class == 'ZoneView':
            view = ZoneView.query.filter_by(id=accessright.object_id).one()
            return 'zone %s view %s' % (view.zone.display_name, view.name)
        elif accessright.object_class == 'Zone':
            zone = Zone.query.filter_by(id=accessright.object_id).one()
            return zone.display_name
        elif accessright.object_class == 'Ippool':
            pool = Pool.query.filter_by(id=accessright.object_id).one()
            return pool.name
        return None
    try:
        return object_str(obj.accessright)
    except:
        return None


def _collection_field_filler(attrname):
    def filler(obj, **kwargs):
        item = kwargs['collection_item']
        if item is not None:
            return getattr(item, attrname, None)
        return None
    return filler


def zone_filler(obj, **kwargs):
    item = kwargs['collection_item']
    if item is not None:
        return item.zone.display_name
    return None


def layer3domain_filler(obj, **kwargs):
    if type(obj) == RR:
        ipblock = obj.ipblock
        if ipblock:
            return ipblock.layer3domain.display_name
    elif type(obj) == Ipblock:
        return ipblock.layer3domain.display_name
    return None


itemname_filler = _collection_field_filler('name')


def default_filler(attr):
    return lambda obj, **kwargs: getattr(obj, attr).display_name if getattr(obj, attr) else None


def attrname_filler(obj, **kwargs):
    change = kwargs['changed_attr']
    if change is not None:
        return change.name
    return None


def newvalue_filler(obj, **kwargs):
    change = kwargs['changed_attr']
    if change is not None:
        if type(obj) == Ipblock and change.name == 'gateway':
            return format_ip(change.new_value, obj.version)
        return format(change.new_value)
    return None


def oldvalue_filler(obj, **kwargs):
    change = kwargs['changed_attr']
    if change is not None:
        if type(obj) == Ipblock and change.name == 'gateway':
            return format_ip(change.old_value, obj.version)
        return format(change.old_value)
    return None


def generate_attr_change_columns():
    return [Column('attrname', String(256), info={'filler': attrname_filler}),
            Column('newvalue', String(256), info={'filler': newvalue_filler}),
            Column('oldvalue', String(256), info={'filler': oldvalue_filler})]


generate_history_table(
    Pool,
    [Column('vlan', Integer, info={'filler': default_filler('vlan')}),
     Column('layer3domain', String(128), info={'filler': default_filler('layer3domain')}),
     Column('address', Numeric(precision=40, scale=0)),
     Column('prefix', Integer)] +
    generate_attr_change_columns(),
    [Pool.name, Pool.version, Pool.description, Pool.vlan, Pool.layer3domain],
    indexes=[Index('ix_name', 'name')])

generate_history_table(
    Ipblock,
    [Column('status', String(64), info={'filler': default_filler('status')}),
     Column('pool', String(128), info={'filler': default_filler('pool')}),
     Column('layer3domain', String(128), info={'filler': default_filler('layer3domain')}),
     Column('vlan', Integer, info={'filler': default_filler('vlan')})] +
    generate_attr_change_columns(),
    [Ipblock.version, Ipblock.address, Ipblock.prefix, Ipblock.priority, Ipblock.gateway,
     Ipblock.status, Ipblock.pool, Ipblock.vlan, Ipblock.layer3domain],
    suppress_events=[Ipblock.version, Ipblock.address, Ipblock.prefix],
    indexes=[Index('ix_address_prefix_version', 'address', 'prefix', 'version')])

generate_history_table(
    Zone,
    generate_attr_change_columns(),
    [Zone.name, Zone.profile],
    fillers={'name': lambda obj, **kwargs: obj.display_name},
    indexes=[Index('ix_name', 'name')])

generate_history_table(
    ZoneView,
    [Column('zone', String(255), index=True, info={'filler': default_filler('zone')})] +
    generate_attr_change_columns(),
    [ZoneView.name, ZoneView.ttl, ZoneView.primary, ZoneView.mail, ZoneView.serial,
     ZoneView.refresh, ZoneView.retry, ZoneView.expire, ZoneView.minimum])

generate_history_table(
    RR,
    [Column('zone', String(255), index=True, info={'filler': lambda obj, **kwargs: obj.view.zone.display_name}),
     Column('layer3domain', String(128), info={'filler': layer3domain_filler}),
     Column('view', String(255), info={'filler': default_filler('view')})] +
    generate_attr_change_columns(),
    [RR.type, RR.name, RR.ttl, RR.comment, RR.value, RR.target, RR.view],
    indexes=[Index('ix_name', 'name')])

generate_history_table(
    Output,
    [Column('zonegroup', String(255), info={'filler': itemname_filler})] +
    generate_attr_change_columns(),
    [Output.name, Output.plugin, Output.comment, Output.db_uri, Output.last_run, Output.status],
    suppress_events=[Output.last_run, Output.status],
    indexes=[Index('ix_name', 'name')])

generate_history_table(
    ZoneGroup,
    [Column('zone', String(255), index=True, info={'filler': zone_filler}),
     Column('view', String(255), info={'filler': itemname_filler})] +
    generate_attr_change_columns(),
    [ZoneGroup.name, ZoneGroup.comment],
    indexes=[Index('ix_name', 'name')])

generate_history_table(
    Group,
    [Column('username', String(255), info={'filler': _collection_field_filler('username')}),
     Column('department_number', Integer, info={'filler': _collection_field_filler('department_number')})] +
    generate_attr_change_columns(),
    [Group.name],
    indexes=[Index('ix_name', 'name')])

generate_history_table(
    GroupRight,
    [Column('group', String(255), index=True, info={'filler': group_filler}),
     Column('right', String(255), info={'filler': right_filler}),
     Column('object', String(255), index=True, info={'filler': object_filler})],
    [])

generate_history_table(
    RegistrarAccount,
    [Column('zone', String(255), index=True),
     Column('action_info', String(4096))],
    [RegistrarAccount.name],
    suppress_events=[RegistrarAccount.name],
    indexes=[Index('ix_name', 'name')])

generate_history_table(
    ZoneKey,
    [Column('zone', String(255), index=True, info={'filler': default_filler('zone')})],
    [ZoneKey.label],
    suppress_events=[ZoneKey.label],
    indexes=[Index('ix_label', 'label')])

generate_history_table(
    Layer3Domain,
    generate_attr_change_columns(),
    [Layer3Domain.name, Layer3Domain.comment],
    indexes=[Index('ix_name', 'name')]
)


def record_history(target, **kwargs):
    '''
    Write one row into target's history table.
    '''
    make_history(target, kwargs['action'], kwargs)


def make_history(target, action, overwrite_values=None, changed_attr=None, collection_item=None):
    '''
    Writes one or multiple rows into the history table corresponding to *target*.
    If a column of the history table has self.info['filler'] set, then this callable will return the value for that column.
    '''
    table = getattr(target, 'history_table', None)
    if table is None:
        return
    values = {'action': action}
    for column in table.c:
        filler = column.info.get('filler', None)
        if filler is not None:
            values[column.name] = filler(target, changed_attr=changed_attr, collection_item=collection_item)
    if overwrite_values is not None:
        values.update(overwrite_values)
    db.session.execute(table.insert().values(**values))


class SelectProxy(object):
    '''
    Keep track of the Select objects created by the generative methods like
    where(), order_by() etc
    '''
    def __init__(self, select, klass, objclass=None):
        self.select = select
        self.klass = klass
        if objclass is None:
            self.objclass = HistorySelect._class_objname(klass)
        else:
            self.objclass = objclass

    def __getattr__(self, name):
        def f(*args, **kwargs):
            self.select = getattr(self.select, name)(*args, **kwargs)
            return self
        return f


class HistorySelect(object):
    '''Helps creating history selects.'''

    def __init__(self):
        self.selects = []

    def add_select(self, klass, objclass=None):
        self.c = klass.history_table.c
        s = SelectProxy(select(), klass, objclass)
        self.selects.append(s)
        return s

    def execute(self, limit, begin=None, end=None, incl=None):
        # Compute all the column names
        all_tables = set([])
        for s in self.selects:
            all_tables.add(s.klass.history_table)
        all_columns = set([])
        for colset in [cols for cols in [table.columns for table in all_tables]]:
            all_columns.update(set([col.name for col in colset]))

        # Append columns to selects
        for s in self.selects:
            table_column_names = [col.name for col in s.klass.history_table.columns]
            columns = [literal(s.objclass).label('objclass')]
            for column in all_columns:
                if column in table_column_names:
                    columns.append(getattr(s.klass.history_table.c, column))
                else:
                    # In mysql, Null UNION Numeric = float
                    column_type = None
                    for table in all_tables:
                        if column in table.c:
                            column_type = table.c[column].type
                            break
                    if isinstance(column_type, Numeric):
                        columns.append(literal(0).label(column))
                    else:
                        columns.append(literal(None).label(column))
            # There are 2 types of columns:
            # columns from the table we select (these have the 'name' attribute)
            # literal columns needed for union with the other selects (these have the 'key' attribute)
            columns = sorted(columns, key=lambda x: x.name if hasattr(x, 'name') else x.key)
            for column in columns:
                s.select.append_column(column)

        max_limit = 5000      # TODO: configuration option?
        if limit is None or limit > max_limit:
            limit = max_limit
        timestamp = sql_expression.column('timestamp')

        def limit_query_timestamp(query):
            if begin is not None:
                query = query.where(timestamp >= begin)
            if end is not None:
                query = query.where(timestamp <= end)
            return query

        def limit_query(query):
            return query.limit(limit).order_by(desc(timestamp))
        for s in self.selects:
            limit_query(s)
        query = union_all(*[db.session.query('*').select_from(limit_query_timestamp(s.select)) for s in self.selects])
        result = db.session.execute(limit_query(query)).fetchall()
        return [HistorySelect._row_info(row, incl) for row in result]

    @staticmethod
    def _class_objname(klass):
        names = {ZoneView: 'zone-view',
                 ZoneGroup: 'zone-group',
                 ZoneKey: 'key',
                 Group: 'group',
                 RegistrarAccount: 'registrar-account'}
        return names.get(klass, klass.__tablename__)

    @staticmethod
    def _row_info(row, incl):
        def action(row):
            def context(prep='in'):
                c = []
                if incl is not None:
                    for attr in incl:
                        attr_value = getattr(row, attr, None)
                        if attr_value is not None:
                            c.append(attr + ' ' + attr_value)
                    if len(c) > 0:
                        return (' %s ' % prep) + ' '.join(c)
                return ''

            use_context_for_attrs = row.objclass in ('rr', 'zone', 'ipblock', 'zone-view')
            if row.action == 'renamed':
                return 'renamed%s' % (' to ' + row.newvalue if row.newvalue else '')
            elif row.action == 'set_attr':
                return '%s %s=%s%s' % (row.action, row.attrname, row.newvalue, context() if use_context_for_attrs else '')
            elif row.action == 'del_attr':
                return '%s %s%s' % (row.action, row.attrname, context() if use_context_for_attrs else '')
            # DNS
            elif row.action in ['created', 'deleted'] and row.objclass in ('rr', 'ippool', 'ipblock', 'zone-view'):
                return '%s%s' % (row.action, context())
            elif row.action in ['added', 'removed'] and row.objclass == 'zone-group':
                return '%s zone %s view %s' % (row.action, row.zone, row.view)
            elif row.action in ['added', 'removed'] and row.objclass == 'output':
                return '%s zone-group %s' % (row.action, row.zonegroup)
            elif row.action in ['add zone', 'remove zone'] and row.objclass == 'registrar-account':
                return '%s %s' % (row.action, row.zone)
            elif row.action in ['published'] and row.objclass == 'registrar-account':
                return row.action_info
            # Groups
            elif row.objclass == 'group' and row.action in ['added', 'removed']:
                if row.username is not None:
                    return '%s user %s' % (row.action, row.username)
                else:
                    return '%s department_number %s %s' % (row.action, row.department_number)
            elif row.objclass == 'group' and row.action in ['granted', 'revoked']:
                return '%s %s%s' % (row.action, row.right, ('' if row.object is None else ' on ' + row.object))
            elif row.objclass == 'group' and row.action == 'department_number':
                return 'set department_number to %s' % row.department_number
            elif row.objclass == 'groupright':
                return '%s %s%s' % (row.action, row.right, ('' if row.object is None else ' on ' + row.object))
            # IP
            elif row.objclass == 'ippool' and (row.action.startswith('create ') or row.action.startswith('delete ')):
                return '%s %s' % (row.action, format_ip(row.address, row.version, row.prefix))
            else:
                return row.action

        def name(row):
            if row.objclass == 'rr':
                return '%s %s %s' % (row.name, row.type, row.value)
            elif row.objclass == 'ipblock':
                return IP(int(row.address), row.prefix, row.version).label()
            elif row.objclass == 'groupright':
                return row.group
            elif row.objclass == 'key':
                return row.label
            else:
                return row.name

        def objclass(name):
            return name if name != 'groupright' else 'group'

        try:
            originating_ip = IP(int(row.call_ip_address), version=row.call_ip_version).label()
        except:
            originating_ip = None

        return {'timestamp': row.timestamp,
                'user': row.user,
                'tool': row.tool if row.tool is not None else 'native',
                'originating_ip': originating_ip,
                'name': name(row),
                'objclass': objclass(row.objclass),
                'action': action(row)}
