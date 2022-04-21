import uuid

from flask import g, current_app, Blueprint
from sqlalchemy import create_engine, text
import click

import dim.models
from dim import db
from dim.models import Zone, OutputUpdate, Output, ZoneView
from dim.models.migrate import migrate


manage_db = Blueprint('manage_db', __name__, cli_group='db')


# as separate function without decorators, so flask cli commands
# can call it without having to pass the context
def _init():
    '''Creates tables and inserts default data'''
    dim.db.create_all()
    dim.models.insert_default_data()


@manage_db.cli.command('init')
def init():
    '''Creates tables and inserts default data'''
    _init()


@manage_db.cli.command('check')
def check():
    '''Checks if the database is accessible and has the correct schema version'''
    if dim.models.SchemaInfo.current_version() == dim.models.SCHEMA_VERSION:
        print("OK")
    else:
        print("Database accessible but has wrong schema version.")


@manage_db.cli.command('clear')
@click.option('-f', '--force', 'force', is_flag=True)
def clear_db(force: bool = False):
    '''Drops tables and runs init'''
    dim.db.drop_all()
    _init()


@manage_db.cli.command('upgrade')
def upgrade():
    '''Upgrades the schema'''
    try:
        migrate()
    except Exception as e:
        print('Error:', str(e))
        return 1


@manage_db.cli.command('script')
@click.argument('filename')
def script(filename):
    '''Runs a SQL script'''
    with open(filename) as f:
        sql = f.read()
    db.engine.execute(sql)


@manage_db.cli.command('fix_ipv6')
@click.argument('s')
def fix_ipv6(s):
    if s.count('::') == 0:
        return s
    else:
        present = s.count(':')
        missing_0 = ['0'] * (8 - present)
        return s.replace('::', ':' + ':'.join(missing_0) + ':')


def update_output_rr_data():
    '''Update output records.content column to match new jdnssec-based format'''
    for output in Output.query.filter(Output.plugin == Output.PDNS_DB):
        engine = create_engine(output.db_uri)
        with engine.begin() as conn:
            conn.execute("UPDATE records SET content=UPPER(content) WHERE type='TLSA'")
            updates = []
            for row in conn.execute("SELECT id, content FROM records WHERE type='AAAA'"):
                updates.append({"id": row.id,
                               "content": fix_ipv6(row.content)})
            conn.execute(text("UPDATE records SET content=:content WHERE id=:id"), updates)


def new_tid():
    g.tid = uuid.uuid4().hex[16:]


@manage_db.cli.command('migrate_new_pdns')
def migrate_new_pdns():
    with current_app.test_request_context():
        new_tid()
        update_output_rr_data()
        # Migrate zone-aliases
        for alias in dim.models.db.session.execute('SELECT name, zone_id FROM zonealias'):
            new_tid()
            aliased_zone = dim.models.db.session.query(Zone).filter_by(id=alias.zone_id).one()
            zone = Zone.create(alias.name, attributes=aliased_zone.get_attrs(), owner=aliased_zone.owner)
            ZoneView.create(zone, aliased_zone.views[0].name, from_profile=aliased_zone)
            for group in aliased_zone.views[0].groups:
                group.views.append(zone.views[0])
                for output in group.outputs:
                    OutputUpdate.send_create_view(zone.views[0], output, OutputUpdate.REFRESH_ZONE)
        # Set nsec3param algorithm to 1 (was incorrectly set to 8 previously)
        for zone in Zone.query.all():
            new_tid()
            zone.set_validity()
            if zone.nsec3_algorithm is not None:
                zone.set_nsec3params(1, zone.nsec3_iterations, zone.nsec3_salt)
        dim.models.db.session.execute('drop table zonealias')
        dim.models.db.session.commit()


@manage_db.cli.command('migrate_pdns_databases')
def migrate_pdns_databases():
    '''Adds the records.rev_name column to each pdns output database'''
    with current_app.test_request_context():
        new_tid()
        for output in Output.query.all():
            if output.plugin != Output.PDNS_DB:
                continue
            engine = create_engine(output.db_uri)
            with engine.begin() as conn:
                if conn.execute(text("SHOW COLUMNS FROM records LIKE 'rev_name'")).scalar():
                    conn.execute(text('UPDATE records SET rev_name=REVERSE(name)'))
                    print('Output %s migrated successfully' % output.name)
                else:
                    print('Output %s has no records.rev_name column' % output.name)
