## Setup DB, DIM and PDNS Server and Shell environment

The following steps assume that you have a minimal CentOS 8 installed.

## Install EPEL:

 `$ sudo dnf install epel-release`

### Install necessary tools:

 `$ sudo dnf install wget bind-utils`

## MariaDB

### Install MariaDB. Setup repository:

```
$ sudo cat <<EOF >/etc/yum.repos.d/mariadb.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos8-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
module_hotfixes=1
EOF
```

### install Software:

```
$ sudo dnf install MariaDB-server

$ sudo systemctl enable mariadb
$ sudo systemctl start mariadb

$ mysql -u root
create database dim;
create database pdns_int;
create database pdns_pub;
-- create users
grant all on dim.* to dim_user@localhost identified by 'dim_pass';
grant insert,update,delete,select on pdns_int.* to dim_pdns_int_user@localhost identified by 'SuperSecret1';
grant insert,update,delete,select on pdns_pub.* to dim_pdns_pub_user@localhost identified by 'SuperSecret2';
grant select on pdns_pub.* to pdns_pub_user@localhost identified by 'SuperSecret3';
grant select on pdns_int.* to pdns_int_user@localhost identified by 'SuperSecret4';
```

## PowerDNS


Setup additional IPs:

```
cat <<EOF >cat /etc/sysconfig/network-scripts/ifcfg-lo-pdns-int
DEVICE=lo
IPADDR=127.1.0.1
NETMASK=255.0.0.0
NETWORK=127.0.0.0
# If you're having problems with gated making 127.0.0.0/8 a martian,
# you can change this to something else (255.255.255.255, for example)
BROADCAST=127.255.255.255
ONBOOT=yes
NAME=loopback
EOF
 
cat <<EOF >cat /etc/sysconfig/network-scripts/ifcfg-lo-pdns-pub
DEVICE=lo
IPADDR=127.2.0.1
NETMASK=255.0.0.0
NETWORK=127.0.0.0
# If you're having problems with gated making 127.0.0.0/8 a martian,
# you can change this to something else (255.255.255.255, for example)
BROADCAST=127.255.255.255
ONBOOT=yes
NAME=loopback
EOF
 
cat <<EOF >cat /etc/sysconfig/network-scripts/ifcfg-lo-pdns-rec-int
DEVICE=lo
IPADDR=127.3.0.1
NETMASK=255.0.0.0
NETWORK=127.0.0.0
# If you're having problems with gated making 127.0.0.0/8 a martian,
# you can change this to something else (255.255.255.255, for example)
BROADCAST=127.255.255.255
ONBOOT=yes
NAME=loopback
EOF
 
cat <<EOF >cat /etc/sysconfig/network-scripts/ifcfg-lo-bind-int
DEVICE=lo
IPADDR=127.4.0.1
NETMASK=255.0.0.0
NETWORK=127.0.0.0
# If you're having problems with gated making 127.0.0.0/8 a martian,
# you can change this to something else (255.255.255.255, for example)
BROADCAST=127.255.255.255
ONBOOT=yes
NAME=loopback
EOF
```

Install repo file and install software::

 cd /etc/yum.repos.d
 wget https://www.monshouwer.eu/download/3rd_party/pdns/el7/pdns.el7.repo
 echo "priority=90" >>pdns-recursor.el7.repo

 yum install pdns-backend-mysql

Fix distros broken config and systemd unit file::

 rm -f /etc/pdns/pdns.conf
 rm -f /usr/lib/systemd/system/pdns.service
 
 cat <<EOF >/etc/systemd/system/pdns@.service
 [Unit]
 Description=PowerDNS %i
 After=network.target mysql.target
 
 [Service]
 Type=simple
 ExecStart=/usr/sbin/pdns_server --config-dir=/etc/pdns/%i --config-name=%i --daemon=no --disable-syslog
 Restart=on-failure
 StartLimitInterval=0
 PrivateTmp=true
 PrivateDevices=true
 CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_SETGID CAP_SETUID CAP_CHOWN CAP_SYS_CHROOT
 NoNewPrivileges=true
 ProtectSystem=full
 ProtectHome=true
 RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
 LimitNOFILE=40000
 
 [Install]
 WantedBy=multi-user.target
 EOF

Setup two PowerDNS instances::

 mkdir /etc/pdns/int /etc/pdns/pub
 
 cat <<EOF >/etc/pdns/int/pdns-int.conf
 # server settings
 setgid=pdns
 setuid=pdns
 version-string=powerdns
 local-port=53
 receiver-threads=10
 guardian=no
 daemon=no
 slave=no
 master=no
 
 # tcp options
 disable-tcp=no
 max-tcp-connections=300
 
 # processing
 local-address=127.1.0.1
 local-ipv6=
 
 out-of-zone-additional-processing=no
 disable-axfr=no
 allow-axfr-ips=127.0.0.0/8,::1
 
 # caches and queues
 cache-ttl=10
 query-cache-ttl=20
 negquery-cache-ttl=60
 queue-limit=2000
 max-cache-entries=200000
 max-queue-length=10000
 
 # webserver
 webserver=no
 
 # tcp-control
 tcp-control-port=
 
 # logs
 loglevel=3
 query-logging=no
 log-dns-details=no
 
 # backend
 launch=gmysql
 gmysql-dnssec
 gmysql-socket=/var/lib/mysql/mysql.sock
 gmysql-dbname=pdns_int
 gmysql-user=pdns_int_user
 gmysql-password=SuperSecret4
 EOF

 cat <<EOF >/etc/pdns/pub/pdns-pub.conf
 # server settings
 setgid=pdns
 setuid=pdns
 version-string=powerdns
 local-port=53
 receiver-threads=10
 guardian=no
 daemon=no
 slave=no
 master=no
 
 # tcp options
 disable-tcp=no
 max-tcp-connections=300
 
 # processing
 local-address=127.2.0.1
 local-ipv6=
 
 out-of-zone-additional-processing=no
 disable-axfr=no
 allow-axfr-ips=127.0.0.0/8,::1
 
 # caches and queues
 cache-ttl=10
 query-cache-ttl=20
 negquery-cache-ttl=60
 queue-limit=2000
 max-cache-entries=200000
 max-queue-length=10000
 
 # webserver
 webserver=no
 
 # tcp-control
 tcp-control-port=
 
 # logs
 loglevel=3
 query-logging=no
 log-dns-details=no
 
 # backend
 launch=gmysql
 gmysql-dnssec
 gmysql-socket=/var/lib/mysql/mysql.sock
 gmysql-dbname=pdns_pub
 gmysql-user=pdns_pub_user
 gmysql-password=SuperSecret3
 EOF

Now start both pdns instances::

 # systemctl start pdns@int
 # systemctl start pdns@pub

use systemctl status to verify that startup worked.

DIM
___

Install rpms of dim, dimclient, ndcli, pdns-output and jdk::

 # The rpms can be found on http://dnsyum.svc.1u1.it/7
 yum install dim-2.11.0-1.el7.x86_64.rpm dim-pdns-output-2.11.0-1.el7.x86_64.rpm jdk-8u181-linux-x64.rpm ndcli-2.11.0-1.el7.noarch.rpm python-dimclient-0.4.2-1.el7.noarch.rpm

modify database and ldap in ``/etc/dim/dim.cfg``, set secret key::

 DB_USERNAME = 'dim_user'
 DB_PASSWORD = 'dim_pass'
 DB_HOST     = 'localhost'
 SQLALCHEMY_DATABASE_URI = 'mysql://%s:%s@%s/dim' % (DB_USERNAME, DB_PASSWORD, DB_HOST)
 DB_LOCK_TIMEOUT = 120
 SECRET_KEY = 'SuperSecretTtestkey'
 
 ### Authentication
 # 'ldap' or None
 AUTHENTICATION_METHOD = None

Install apache httpd and mod_wsgi::

 yum install mod_wsgi mod_ssl

setup wsgi.conf::

 cat <<EOF >/etc/httpd/conf.d/wsgi.conf
 WSGIApplicationGroup dim
 WSGIScriptAlias /dim /opt/dim/dim.wsgi
 EOF

Setting up SSL is left as an exercise to the reader.

start apache ``systemctl enable httpd; systemctl start httpd``

Run ``/opt/dim/bin/manage_db init`` to create tables

create a ``.ndclirc`` in your home::

 cat <<EOF >~/.ndclirc
 server=http://localhost/dim
 username=admin
 EOF

make sure that ``bash-completion`` is installed (to enable ``ndcli`` completion)::

 sudo yum install bash-completion

run ``ndcli show server-info`` to test connection to DIM. Should output information about python and db used.

DIM output
__________

Edit config file::

 cat <<EOF >/etc/dim/pdns-output.properties
 # dim database connection parameters
 db.serverName=127.0.0.1
 db.portNumber=3306
 db.databaseName=dim
 db.user=dim_user
 db.password=dim_pass
 
 # Timeout in seconds for getting the pdns_poller lock which prevents multiple pdns-output instances from running
 lockTimeout=120
 
 # Delay in seconds used when polling the dim outputupdate table
 pollDelay=1
 
 # Delay in seconds before retrying a failed update
 retryInterval=60
 
 # Debug option to print to stdout transaction ids after processing them
 printTxn=false
 
 # Max size of a sql query in bytes
 # should be less than the configured max_allowed_packet in mysql
 maxQuerySize=4000000
 
 useNativeCrypto=true
 EOF

Create Service file::

 cat <<EOF >/etc/systemd/system/pdns-output.service
 [Unit]
 Description=DIM to PowerDNS DB
 After=network.target mysql.target
 
 [Service]
 Type=simple
 ExecStart=/bin/java -jar /opt/dim/pdns-output.jar
 Restart=on-failure
 StartLimitInterval=0
 PrivateTmp=true
 PrivateDevices=true
 CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_SETGID CAP_SETUID CAP_CHOWN CAP_SYS_CHROOT
 NoNewPrivileges=true
 ProtectSystem=full
 ProtectHome=true
 RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
 LimitNOFILE=40000
 
 [Install]
 WantedBy=multi-user.target
 EOF

Start service::

 systemctl enable pdns-output
 systemctl start pdns-output

ndcli Basics
