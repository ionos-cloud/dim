from dim import db
from dim.models import Zone, RegistrarAction
from dim.autodns3 import get_action_keys
from dim.errors import DimError
from tests.util import RPCTest, raises


class Autodns3Test(RPCTest):
    def setUp(self):
        RPCTest.setUp(self)
        self.r.zone_create('a.de')
        self.r.registrar_account_create('ra', 'autodns3', '', '', '', '')
        self.r.registrar_account_add_zone('ra', 'a.de')

    def get_action(self, zone):
        zone = Zone.query.filter_by(name=zone, profile=False).first()
        assert zone
        action = RegistrarAction.query.filter_by(zone=zone).filter(
            RegistrarAction.status.in_(['running', 'pending'])).first()
        assert action
        return action

    def start(self, zone):
        self.r.registrar_account_update_zone(zone)
        action = self.get_action(zone)
        action.status = 'running'
        db.session.commit()

    def finish_action(self, zone, error):
        action = self.get_action(zone)
        action.error = error
        action.status = 'failed' if error else 'done'
        action_keys = get_action_keys(action)
        for key in action_keys:
            key.registrar_action = None
        if not error:
            action.zone.update_registrar_keys(action_keys)
        db.session.commit()

    def fail(self, zone):
        self.finish_action(zone, 'error')

    def success(self, zone):
        self.finish_action(zone, None)

    def check_pending(self, zone, expected):
        assert len(self.r.zone_registrar_actions(zone)) == expected

    def first_key(self, zone):
        return [k['label'] for k in self.r.zone_list_keys(zone) if k['type'] == 'KSK'][0]

    def test_list_actions(self):
        self.r.zone_dnssec_enable('a.de')
        self.check_pending('a.de', 1)
        self.start('a.de')
        self.check_pending('a.de', 1)
        self.fail('a.de')
        self.check_pending('a.de', 1)
        self.start('a.de')
        self.check_pending('a.de', 1)
        self.success('a.de')
        self.check_pending('a.de', 0)

    def test_list_actions2(self):
        self.r.zone_dnssec_enable('a.de')
        self.check_pending('a.de', 1)
        self.start('a.de')
        self.check_pending('a.de', 1)
        self.r.zone_create_key('a.de', 'ksk')
        self.check_pending('a.de', 2)

    def test_no_op(self):
        self.check_pending('a.de', 0)

    def test_rollover(self):
        self.r.zone_dnssec_enable('a.de')
        old_key = self.first_key('a.de')
        self.start('a.de')
        self.success('a.de')
        self.r.zone_create_key('a.de', 'ksk')
        self.start('a.de')
        self.success('a.de')
        self.r.zone_delete_key('a.de', old_key)
        self.check_pending('a.de', 1)
        self.start('a.de')
        self.check_pending('a.de', 1)
        self.success('a.de')
        self.check_pending('a.de', 0)
        self.r.zone_delete_key('a.de', self.first_key('a.de'))
        self.check_pending('a.de', 1)
        self.start('a.de')
        self.success('a.de')
        self.check_pending('a.de', 0)
        with raises(DimError):
            self.start('a.de')

    def test_ra_list_zones(self):
        self.r.zone_dnssec_enable('a.de')
        self.start('a.de')
        self.fail('a.de')
        r = self.r.registrar_account_list_zones('ra', include_status=True)
        assert len(r) == 1
        assert r[0]['zone'] == 'a.de'
        assert r[0]['status'] == 'failed'
        assert r[0]['error'] == 'error'

    def test_delete(self):
        self.r.zone_dnssec_enable('a.de')
        self.start('a.de')
        with raises(DimError):
            self.r.zone_delete_key('a.de', self.first_key('a.de'))
        with raises(DimError):
            self.r.zone_delete('a.de')
        with raises(DimError):
            self.r.registrar_account_delete_zone('ra', 'a.de')
        self.r.zone_group_create('zg')
        self.r.zone_group_add_zone('zg', 'a.de')
        with raises(DimError):
            self.r.zone_group_remove_zone('zg', 'a.de')
        self.r.output_create('o', plugin='pdns-db', db_uri='')
        self.r.output_add_group('o', 'zg')
        with raises(DimError):
            self.r.output_remove_group('o', 'zg')
