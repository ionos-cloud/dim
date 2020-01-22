===========
 Internals
===========

This chapter contains information for developers working on dim.

Setting Up a Development Environment
====================================

1. Install virtualenv, pip and sphinx, the mysql server and the needed libraries (non-python): sasl, openldap, mysqlclient::

    apt-get install python-virtualenv python-pip python-sphinx build-essential python2.6-dev libmysqlclient-dev libsasl2-dev libldap2-dev mysql-server

2. Create a virtualenv and install the python libraries::

    virtualenv dimvenv --python=python2.6 --no-site-packages
    . dimvenv/bin/activate
    pip install -r requirements.txt

3. Create a mysql database and user::

    create database netdot;
    grant all privileges on netdot.* to netdot_user@localhost identified by 'netdot_pass';

4. Copy dim/defaults.py to etc/dim.cfg::

    cp dim/defaults.py etc/dim.cfg

5. Edit etc/dim.cfg, setting ``SECRET_KEY`` to anything and ``AUTHENTICATION_METHOD = None`` (optional)

6. Create the tables::

    ./manage_db init

7. You can now start the development server::

    ./manage_dim runserver

8. To use ndcli with the development server, set the server url in ~/.ndclirc or use the --server option of ndcli (man ndcli for more info). If you set up ``AUTHENTICATION_METHOD = None`` in step 5, you can log in as the admin user with any password.


DNSSEC Setup
============

1. Install a pdns-server package built with ``--enable-experimental-pkcs11`` and mysql

2. Create a dim virtualenv with virtualenvwrapper

3. Run ``testenv/setup-debian.sh``

Or use docker::

    cd $DIM/testenv

    docker build -t dim . && docker run -ti -p 5000:5000 -v ~/dev/dim/dim/dim:/opt/dim/lib/python2.6/site-packages/dim -v ~/dev/dim/ndcli/dimcli:/opt/dim/lib/python2.6/site-packages/dimcli -v ~/dev/dim/requirements:/root/requirements dim

To run tests add ``runtest`` to the ``docker run`` command.


Release Checklist
=================

dim:

- migrate_diff
- edit CHANGES
- git tag

ndcli:

- edit CHANGES
- git tag


PowerDNS Output
===============

The PowerDNS output uses a queue for pending updates. The updates can be:

- create_rr
- delete_rr
- update_soa
- create_zone (creates pdns domain)
- refresh_zone (recreates pdns domain)
- delete_zone (deletes pdns domain)

The update queue is implemented as a table, but this could be easily changed if
needed.

``manage_dim pdns`` executes updates from the update queue asynchronously. To
prevent the slower outputs from increasing the overall latency, a thread pool is
used.

To keep the database load to a minimum a single thread is polling the database
and distributing tasks to the thread pool, taking care to preserve the order of
the updates seen by each output. If an update fails, it is retried after 5
minutes. During this time no other updates for the output are processed.

To protect against multiple instances of ``manage_dim pdns`` applying the same
updates out of order, a lock is held for each output. Also, a lock is used by
the polling thread to prevent multiple instances from seeing the same updates in
the common case.

If a dim transaction generates multiple updates, they will be grouped in an
update transaction and applied together atomically to the pdns database.

Known Issues
------------

- Deleting an output with pending updates and/or nonempty zone groups will not
  delete the zones managed in PowerDNS. This means that if another output is
  created for the same PowerDNS database with some of the original zones, the
  updates will be blocked because dim will recognize the zones as manually
  managed.
- A manually managed pdns domain with an identical SOA as a dim zone view will
  be overwritten without warning.
