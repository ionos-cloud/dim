import logging

import ldap3
from flask import current_app as app


def check_credentials(username, password):
    user_dn = app.config['LDAP_USER_DN'] % username
    if app.config['LDAP_SEARCH_BASE']:
        user_dn += "," + app.config['LDAP_SEARCH_BASE']

    server = ldap3.Server(app.config['LDAP_SERVER'])
    conn = ldap3.Connection(server, user=user_dn, password=password, client_strategy=SAFE_SYNC)
    if not conn.bind():
        logging.info('LDAP login for user %s failed: %s', username, conn.result)
        return False
    return True
