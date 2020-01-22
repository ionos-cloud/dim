from dim import db
from .util import (get_session_username, get_session_tool, get_session_ip_address, # noqa
                   get_session_ip_version, WithAttr, TrackChanges)
from .schema import SCHEMA_VERSION, SchemaInfo
from .ip import (Pool, Vlan, IpblockStatus, AllocationHistory, PoolAttr, Ipblock, IpblockAttr, # noqa
                 IpblockAttrName, Layer3Domain, FavoritePool)
from .dns import (Zone, ZoneView, RR, RRType, Output, OutputUpdate, ZoneGroup, # noqa
                  ZoneKey, RegistrarAccount, RegistrarAction, FavoriteZoneView)
from .rights import User, UserType, Group, AccessRight, GroupRight, GroupMembership, Department # noqa
from .history import record_history # noqa


def insert_default_data():
    db.session.add_all([IpblockStatus(name='Container'),
                        IpblockStatus(name='Discovered'),
                        IpblockStatus(name='Dynamic'),
                        IpblockStatus(name='Reserved'),
                        IpblockStatus(name='Subnet'),
                        IpblockStatus(name='Static'),
                        IpblockStatus(name='Available'),
                        IpblockStatus(name='Delegation'),

                        UserType(name='Admin'),
                        UserType(name='Operator'),
                        UserType(name='User')])
    db.session.add(User(username='admin', user_type='Admin'))
    db.session.add(Layer3Domain(name='default', type=Layer3Domain.VRF, rd=Layer3Domain.parse_rd('8560:1')))
    db.session.add(SchemaInfo(id=1, version=SCHEMA_VERSION))
    db.session.commit()


def clean_database():
    db.session.execute('SET foreign_key_checks = 0')
    for t in reversed(db.Model.metadata.sorted_tables):
        db.session.execute(t.delete())
    db.session.execute('SET foreign_key_checks = 1')
    insert_default_data()
