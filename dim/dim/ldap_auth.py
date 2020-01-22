import logging

import ldap
from flask import current_app as app


def check_credentials(username, password):
    user_dn = app.config['LDAP_USER_DN'] % username
    if app.config['LDAP_SEARCH_BASE']:
        user_dn += "," + app.config['LDAP_SEARCH_BASE']
    conn = ldap.initialize(app.config['LDAP_SERVER'])
    try:
        conn.bind_s(user_dn, password)
        return True
    except Exception as e:
        logging.info('LDAP login for user %s failed: %s', username, e)
        return False
