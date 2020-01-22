LDAP Integration
================

``manage_dim sync_ldap`` is a script handling the LDAP integration. It must be run regularly to
synchronize de DIM database with LDAP.

A user-group may be associated with an LDAP department at creation::

    ndcli create user-group ldap-named <g>

or later::

    ndcli modify user-group <g> set department <department-id>

If a user-group is associated with a department, its name and user list will automatically be
updated by sync_ldap to match the data in LDAP. Any users belonging to the department will be
created if they don't exist yet.

If the department is deleted from LDAP, the associated user-group will lose this link and will
become a regular user-group.

If a user name is found in LDAP, its ldap_cn and ldap_uid will also be updated by sync_ldap.
