# Quick Start Guide

### `ndcli`

This name roots back to NetDot CLI. We never managed to change it after the creation of DIM.

Use `man ndcli` for complete list of commands.

Use `-h` or <TAB><TAB> to see the valid set of sucommands

Use `-d` to see API calls made.

Use `-H` to get a parsing friendly output.

To limit memory usage on the server machine many commands are limit the result set. Please use `-L` to override.

# Setup templates

### Setup DNS Zone Profiles

Every DNS Zone you create needs some basic NS and MX records and settings in the SOA adjusted to your needs. To avoid typing this every time lets create zone-profiles.

For a small setup which only has internal and public zones, two zone-profiles are recommended.
	
create zone-profile public
```
ndcli create zone-profile public
ndcli modify zone-profile public create rr @ NS ns1.example.com.
ndcli modify zone-profile public create rr @ NS ns2.example.com.
ndcli modify zone-profile public set ttl 86400
ndcli modify zone-profile public set primary ns1.example.com.
ndcli modify zone-profile public set mail dnadmins@example.com
ndcli modify zone-profile public set minimum 600
ndcli modify zone-profile public set refresh 3600
ndcli modify zone-profile public set expire 2592000
```
	
create zone-profile internal
```
ndcli create zone-profile internal
ndcli modify zone-profile internal create rr @ NS ins1.internal.test.
ndcli modify zone-profile internal create rr @ NS ins2.internal.test.
ndcli modify zone-profile internal set primary ins1.internal.test.
ndcli modify zone-profile internal set mail dnsadmins@example.com
ndcli modify zone-profile internal set minimum 60
ndcli modify zone-profile internal set ttl 86400
```

create zones
```
ndcli create zone example.com profile public
ndcli create zone internal.test profile internal
ndcli create zone 10.in-addr.arpa profile internal
```

Map zones to zone-groups to PowerDNS databases.
```
ndcli create zone-group internal
ndcli create zone-group public

ndcli modify zone-group internal add zone internal\.test
ndcli modify zone-group internal add zone 10.in-addr.arpa
ndcli modify zone-group internal add zone example\.com
ndcli modify zone-group public add zone example\.com 

ndcli create output pdns-int plugin pdns-db db-uri mysql://dim_pdns_int_user:SuperSecret1@127.0.0.1:3306/pdns_int
ndcli create output pdns-pub plugin pdns-db db-uri mysql://dim_pdns_pub_user:SuperSecret2@127.0.0.1:3306/pdns_pub

ndcli modify output pdns-int add zone-group internal 
ndcli modify output pdns-pub add zone-group public
```
This looks complicated but allows you to have the same zone in multiple pdns dbs.

Verify that DNS resolution is now working
```
$ dig NS internal.test @127.1.0.1

; <<>> DiG 9.11.26-RedHat-9.11.26-4.el8_4 <<>> NS internal.test @127.1.0.1
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 3217
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1220
;; QUESTION SECTION:
;internal.test.			IN	NS

;; ANSWER SECTION:
internal.test.		86400	IN	NS	ins1.internal.test.
internal.test.		86400	IN	NS	ins2.internal.test.

;; Query time: 2 msec
;; SERVER: 127.1.0.1#53(127.1.0.1)
;; WHEN: Tue Jun 22 17:31:44 CEST 2021
;; MSG SIZE  rcvd: 80
```

### Setup your IP Space - Containers

You manage your IP-Space in DIM with the following objects: `containers`, `pools` and `subnets`. For a minimal layer 2 Management you can tag your pools with `vlan` information.

For an enterprise environment where you have several v4 /16 and v6 /32 aggregates to manage, you typically add these directly as containers.

All IP objects are uniquely identified by prefix, length and layer3domain. It is not possible to have a /24 container and a /24 subnet of the same prefix. In this case please create two /25 subnets.

In a home user environment I recommend to just add rfc1918 v4 and 2000::/3 v6
containers:
```
ndcli create container 10.0.0.0/8 origin:rfc1918 reverse_dns_profile:internal
ndcli create container 192.168.0.0/16 origin:rfc1918 reverse_dns_profile:internal
ndcli create container 172.16.0.0/12 origin:rfc1918 reverse_dns_profile:internal
ndcli create container 100.64.0.0/10 origin:rfc6598 reverse_dns_profile:internal
ndcli create container 2000::/3 origin:rfc4291 reverse_dns_profile:public
ndcli create container 2001:db8::/32 origin:rfc3849 "comment:Documentation Prefix"
ndcli create container fc00::/7 origin:rfc4193 "comment:Unique Local Unicast" reverse_dns_profile:internal
ndcli create container fe80::/10 origin:rfc4291 "comment:Link-Scoped Unicast"
ndcli create container ff00::/8 origin:rfc4291 "comment:Multicast"
ndcli create container 9.0.0.0/8 origin:IBM-DEMO "comment:IBM - DEMO only"
```
	
### Setup your IP Space - IP Pools (v4)

IP Pools help you as an abstraction between prefixes and consumers. The consumers receive the pool name and use the api to allocate and free ip addresses.
If the pool runs out of free ip addresses, the network team can add another prefix to the pool and the consumers do not need to change anything.
	
This documentation composes pool names from the following information
- location - 2 letter country, 3 letter UN - LOC code, 2 letter street abbreviation
- short description of use
- vlan
- ip version
- Scope (live, non-live)

create ip pools
```
ndcli create container 10.10.0.0/16 "comment:Data Center Networks"
ndcli create container 10.10.0.0/20 "comment:Database Servers Networks"
ndcli create pool de-fuh-bar-pg-600 vlan 600
ndcli modify pool de-fuh-bar-pg-600 add subnet 10.10.0.0/28 gw 10.10.0.1
```
The reverse zone `0.10.10.in-addr.arpa` was automatically created. It was automatically added to all zone-groups where the next less specific zone resides.
```
dig SOA 0.10.10.in-addr.arpa @127.1.0.1
```
just works.
	
Give the router ip a DNS name `ndcli create rr v600.net.example.com. a 10.10.0.1`.

```
dig v600.net.example.com @127.1.0.1
dig -x 10.10.0.1 @127.1.0.1
```
just work

### using IP-Pools (v4)
The ip-pool can now be used like this:
```
ndcli create rr db1234.db.internal.test. from de-fuh-bar-pg-600
INFO - Marked IP 10.10.0.2 from layer3domain default as static
INFO - Creating RR db1234.db A 10.10.0.2 in zone internal.test
INFO - Creating RR 2 PTR db1234.db.internal.test. in zone 0.10.10.in-addr.arpa
created:2021-06-22 17:43:53.546471
gateway:10.10.0.1
ip:10.10.0.2
layer3domain:default
mask:255.255.255.240
modified:2021-06-22 17:43:53.546509
modified_by:user
pool:de-fuh-bar-pg-600
ptr_target:db1234.db.internal.test.
reverse_zone:0.10.10.in-addr.arpa
status:Static
subnet:10.10.0.0/28
```
The user gets the DNS entries and all information needed for OS installation. And the new name start resolving practically immediately.

### using only IP funtionality of IP-Pools (v4


### Setup your IP Space - IP Pools (v6)

### using IP-Pools (v6)


ndcli create pool de-bwi-ur-dcn-db-601 vlan 601 
ndcli modify pool de-wzt-bs-dcn-db-601 add subnet 10.10.1.0/24 gw 10.10.1.1
	
ndcli create container 10.20.0.0/20 "comment:knx gateways"
ndcli create pool de-wzt-bs-knx-1023 vlan 1023
ndcli modify pool de-wzt-bs-knx-1023 add subnet 10.20.0.0/28 gw 10.20.0.1
 
ndcli create container 10.24.0.0/13 "comment: all WLAN networks"
ndcli create container 10.30.0.0/15 "comment: all internal WLAN networks"
ndcli create pool de-wzt-bs-wlan-1023 vlan 1023
ndcli modify pool de-wzt-bs-wlan-1023 add subnet 10.31.0.0/25 gw 10.31.0.1
ndcli create container 2001:db8:776c::/48 "comment:all v6 WLAN networks"
ndcli create container 2001:db8:776c::/49 "comment:internal v6 WLAN networks"
ndcli create pool de-wzt-bs-wlan-1023_v6 vlan 1023
ndcli modify pool de-wzt-bs-wlan-1023_v6 add subnet 2001:db8:776c:1023::/64 gw 2001:db8:776c:1023::1
ndcli create container 10.24.0.0/16 "comment: all guest WLAN networks"
ndcli create pool de-wzt-bs-guest-wlan-1032 vlan 1032
ndcli modify pool de-wzt-bs-guest-wlan-1032 add subnet 10.24.12.128/25 gw 10.24.12.129
ndcli create container 2001:db8:776c:8000::/49 "comment: all guest v6 WLAN networks"
ndcli create pool de-wzt-bs-guest-wlan-1032_v6 vlan 1032
ndcli modify pool de-wzt-bs-guest-wlan-1032_v6 add subnet 2001:db8:776c:8032::/64 gw 2001:db8:776c:8032::1
ndcli create pool de-wzt-bs-web-2001 vlan 2001
ndcli modify pool de-wzt-bs-web-2001 add subnet 9.2.1.0/25 gw 9.2.1.1
```
If ``guest-wlan`` is to small, then you can just add another subnet::

 ndcli modify pool de-wzt-bs-wlan-1023 add subnet 10.31.0.128/25 gw 10.31.0.129

(Yes, you need to manually adapt router and dhcp configuration.) (For DHCP a collegaue will release config generator and some tools)

Resizing subnets is also supported, described in the power user documentation (tbw).

Please do a ``ndcli list containers`` to verify that the structure created is correct.

Setup DNS zones
===============

public zone::

 ndcli create zone company.com profile public

create a resource record for the router::

 ndcli create rr gw.company.com. a 9.2.1.1

you also just use the next free ip from a pool::

 ndcli create rr www.company.com. from de-wzt-bs-web-2001

you also just use the next free ip from a vlan (if the vlan number only matches one pool)::

 ndcli create rr mail.company.com. from 2001
 ndcli create rr openfire.company.com. from 2001

The public zone should also have a MX and some obvious CNAMES::

 ndcli create rr company.com. MX 10 mail.company.com.
 ndcli create rr imap.company.com. cname mail.company.com.
 ndcli create rr smtp.company.com. cname mail.company.com.
 ndcli create rr chat.company.com. cname openfire.company.com.
 ndcli create rr _xmpp-client._tcp.company.com. SRV 5 0 5222 openfire.company.com.
 ndcli create rr _xmpp-server._tcp.company.com. SRV 5 0 5269 openfire.company.com.

internal zone::

 ndcli create zone internal.local profile internal
 ndcli create rr ins1.internal.local. a 127.1.0.1
 ndcli create rr ins1.internal.local. a 127.1.0.2
 ndcli create rr knx-gw.internal.local. a 10.20.0.1
 ndcli create rr wlan-gw.internal.local. a 10.31.0.1
 ndcli create rr wlan-gw.internal.local. aaaa 2001:db8:776c:1023::1
 ndcli create rr wlan-guest-gw.internal.local. a 10.24.12.129
 ndcli create rr wlan-guest-gw.internal.local. aaaa 2001:db8:8000:1032::1
 ndcli create rr wlan-guest-gw2.internal.local. a 10.31.0.129
 ndcli create rr vl600.bs.wzt.de.net.internal.local. a 10.10.0.1
 ndcli create rr vl601.ur.bwi.de.net.internal.local. a 10.10.1.1
 
zone with a internal and a public view::

 ndcli create zone example.com profile public
 ndcli modify zone example.com create view internal profile internal
 ndcli modify zone example.com rename view default to public
 ndcli create rr www.example.com. a 9.2.1.13 view internal public
 ndcli create rr knx.example.com. a 10.20.0.3 view internal

As you can these from the command output dim takes care of marking IPs as used and creating reverse zone entries.

Using ``ndcli list zone example.com view public`` you can see the records which will be published on public name server. Listing zones company.com, internal.local and example.com view internal left as an exercise to the reader. You can use ``ndcli list zones`` to get an overview.

Using sub-zones with DIM
========================

First create some records to demonstrate how sub-zone work in DIM::

 ndcli create rr dbs001.db.internal.local. from 600
 ndcli create rr dbs002.db.internal.local. from 600

DIM has automatically selected the "most specific zone" for you to place the record there.

Now create a sub-zone::

 ndcli create zone db.internal.local profile internal

The commands output shows you that the dbs001 and 2 records are automatically moved. If the parent-zone is member of a zone-group and/or has user-groups assigned, these are automatically inherited.

Create another record::

 ndcli create rr dbs003.db.internal.local. from 601

record is created in most specific zone.

If you need to get the delegations right between zones where both parent- and sub-zone are managed in DIM, please use the ``ndcli modify zone Z create rr R`` syntax documented in the man page.

sub-zones are mostly used to grant other rights on the sub-zone than on the parent-zone.

Setup zone-groups
=================

Zone groups are needed simplify the process of assigning the all correct outputs to a zone. I you design your zone-goup setup once carefully, you'll probably have never to touch it again::

 ndcli create zone-group internal-global
 ndcli create zone-group public-global

 ndcli create zone-group view-internal-global
 ndcli create zone-group view-public-global

assign the zones to zone-groups::

 ndcli modify zone-group internal-global add zone internal.local
 ndcli modify zone-group internal-global add zone db.internal.local
 ndcli modify zone-group internal-global add zone 0.20.10.in-addr.arpa
 ndcli modify zone-group internal-global add zone 0.31.10.in-addr.arpa
 ndcli modify zone-group internal-global add zone 12.24.10.in-addr.arpa
 ndcli modify zone-group public-global add zone company.com
 ndcli modify zone-group public-global add zone 1.2.9.in-addr.arpa
 ndcli modify zone-group public-global add zone 2.3.0.8.c.6.7.7.8.b.d.0.1.0.0.2.ip6.arpa
 ndcli modify zone-group public-global add zone 3.2.0.1.c.6.7.7.8.b.d.0.1.0.0.2.ip6.arpa
 ndcli modify zone-group view-internal-global add zone example.com view internal
 ndcli modify zone-group view-public-global add zone example.com view public

Setup outputs
=============

outputs::

 ndcli create output pdns_int plugin pdns-db db-uri mysql://dim_pdns_int_user:SuperSecret1@localhost:3306/pdns_int
 ndcli create output pdns_pub plugin pdns-db db-uri mysql://dim_pdns_pub_user:SuperSecret2@localhost:3306/pdns_pub

assign zone-groups::

 ndcli modify output pdns_int add zone-group internal-global
 ndcli modify output pdns_pub add zone-group public-global
 ndcli modify output pdns_int add zone-group view-internal-global
 ndcli modify output pdns_pub add zone-group view-public-global

Use ``ndcli list outputs -t`` to see output plugins transfering records.

Once ``pending_records`` is zero you should try and query 127.1.0.1 and 127.2.0.1 for example.com. ``dig`` should return different values.

Please review the Operations Guide for hints on monitoring the transport of DNS Resource records to PowerDNS.

In a typical setup you will now also need to provide dns recursive service for your internal computers.

Below there are 2 more sections on pdns-recursor and dim-bind-file-agent.

DNSSec
======

DIM makes it easy to use DNSSec. Switch on DNSSec for example.com (remember: there is tab completion and -h)::

 ndcli modify zone example\.com dnssec enable 8 ksk 4096 zsk 2048 nsec3 31 salted

(Sign Zone example.com with algorithm 8 (RSA/SHA-256) 4096 bit key signing key, 2048 bit zone signing key, with NSEC3 31 iterations, salted. Salt is generated automatically.

Check with dig::

 dig +dnssec example.com @127.2.0.1

DNSSec parameters can be seen with ``ndcli show zone example.com``. You can modify these parameters with ``ndcli modify zone Z set attr P:V``.

To see DS records::

 ndcli list zone example.com ds

Example ZSK key roll::

 ndcli modify zone example\.com dnssec new zsk

Wait at minimum 24h.

Identify and delete old ZSK::

 ndcli list zone example.com keys
 ndcli modify zone example\.com dnssec delete key example.com_zsk_20180827_132749335059

KSK roll works identical.

setting/updating DS with AutoDNS3 API at registry
_________________________________________________

If your domain is registered at internetX you can use the AutoDNS3 API adapter to update DS records::

 ndcli create registrar-account ad3-example.com plugin autodns3 url http://autodns.com user USER password PASSWORD subaccount SUBACCOUNT
 ndcli modify registrar-account ad3-example\.com add example\.com
 ndcli list zone example\.com registrar-actions

Run ``/opt/dim/bin/manage_dim autodns3`` to process the registrar actions. Creating a systemd-unit file to start this daemon at boot time is left as an exercise to the reader. In ``/etc/dim/dim-autodns3-plugin.cfg`` you can set a http proxy to connect to autodns3 url.

At the moment the only DS records can be set. If this works for us we plan to implement functions to update delegations, create and delete domains.

SOME BIG FAT WARNINGS:
______________________

Read RFC4641 and/or RFC6781.

You must run ``/opt/dim/bin/manage_dim update_validity`` every day to make sure that RRSIGs are kept up to date.

You must create a cron job that regularly checks your signed zones for validity. Check dnssec_mon script on github.

===============
User Management
===============

DIM does not implement password store. If it is configured to use LDAP, it simply checks that the provided username/password can login to the provided LDAP configuration.

DIM does implement a authorization system.

DIM comes with a preconfigured admin user. It should be deleted in a live system.

A user with ``user_type_id`` in ``user`` table set to 1 is a super-admin. No restrictions apply for this user. This value is only read when a user session is created, so if you change a user_type_id, the user needs to login again.

Normal users have ``user_type_id`` 3. 2 is unused.

Entries in the user table are created after the first successful login. With ``/opt/dim/bin/manage_dim ldap_sync`` you can sync all users in configured ``LDAP_URL`` into DIM.

With ndcli rights in DIM can only be granted to user groups not to individual users.

DIM has a network admin and a DNS admin role.

Network admins can create/modify/delete containers and pools. Network admins can grant the allocate right on pools.

DNS admins can create/modify/delete zones, zone-groups and outputs. DNS admins can grant create_rr, delete_rr and zone_admin on zones and zone-create to user-groups.

Both types of admins can create user-groups.

In our organization we DNS admins create user-groups prefixed with 'DNS' and grant DNS related rights o them. Network admins have unprefixed user-groups and grant rights to them.

==========
Audit logs
==========

DIM keeps history of all data changing transactions in the system. Yon can query the history records with ndcli::
 ndcli history -h
 Usage: ndcli history [<subcommand>]
 
 Subcommands:
  [any]                any
  ipblock              ipblock
  output               output
  outputs              outputs
  pool                 pool
  registrar-account    registrar-account
  rr                   rr
  rrs                  rrs
  user                 user
  user-group           user-group
  user-groups          user-groups
  zone                 zone
  zone-group           zone-group
  zone-groups          zone-groups
  zone-profile         zone-profile
  zone-profiles        zone-profiles
  zones                zones
 
 Options for ndcli history:
  -b --begin              begin timestamp (default: None)
  -e --end                end timestamp (default: None)
  -L --limit              max number of results (default: 10)
  -H --script             scripting mode output (no headers, tab between fields)
 
 Options for ndcli:
  -d --debug              also print DEBUG messages
  -D --detailed           detailed return codes
  -h --help               display usage information
  -p --password           Dim password
  -q --quiet              don't print WARNING or INFO messages
  -s --server             Dim server URL
  -u --username           Dim username
  -V --version            print version and exit
  -w --warnings           don't print INFO messages



========
Appendix
========

Importing Zones
===============

``dig axfr some.zone @some.host | ndcli import zone some.zone``

Graphical Frontend
==================

Please wait for this document to be updated for DIM 3.0

Multiple RFC1918 IP Spaces
==========================

Please wait for this document to be updated for DIM 3.0

Proxied user authentication
===========================

See developer Guide for this feature that allows easy integration with other tools.

dim-bind-file-agent
===================

Yes, it is a only a proof of concept. But it works fine and solves problems.

DNSSec signed zones are not possible with dim-bind-file-agent.

retrieve code from git::

 yum install git
 cd /opt
 GIT_SSL_NO_VERIFY=true git clone https://bitbucket.1and1.org/scm/dim/dim-bind-file-agent.git

Setup a new output and assign zone-group::

 ndcli create output bind-int plugin bind
 ndcli modify output bind-int add zone-group internal-global
 ndcli modify output bind-int add zone-group view-internal-global

install bind and create config::

 yum install bind
 mkdir -p /var/named/dim-zones
 cat <<EOF >/etc/named.conf
 options {
	listen-on port 53 { 127.4.0.1; };
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { localhost; };

	/*
	 - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion.
	 - If you are building a RECURSIVE (caching) DNS server, you need to enable 
	   recursion.
	 - If your recursive DNS server has a public IP address, you MUST enable access 
	   control to limit queries to your legitimate users. Failing to do so will
	   cause your server to become part of large scale DNS amplification 
	   attacks. Implementing BCP38 within your network would greatly
	   reduce such attack surface
	*/
	recursion yes;

	dnssec-enable yes;
	dnssec-validation yes;

	/* Path to ISC DLV key */
	bindkeys-file "/etc/named.iscdlv.key";

	managed-keys-directory "/var/named/dynamic";

	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
 };
 
 logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
 };
 
 zone "." IN {
	type hint;
	file "named.ca";
 };
 include "/var/named/dim.zones";
 /*include "/etc/named.rfc1912.zones";*/
 include "/etc/named.root.key";
 EOF

and now run the zone exporter::

 /opt/dim-bind-file-agent/dim-bind-file-agent -s http://localhost/dim -u admin -p '' -o bind-int -i /srv/named/dim.zones -z /srv/named/zones

Please take a look into srv/named/dim.zones and the generated zone files in /srv/named/zones.

Start bind and check::

 setenforce 0 # disable SELinux to allow bind to load files
 systemctl start named
 dig internal.local @127.4.0.1

Planed features after opensourcing
__________________________________

* define a set of zone properties to control ``also-notify``, ``allow-transfer`` from DIM
* trigger ``rndc reload <zone>`` only for changed zones
* provide systemd unit file

pdns-recursor
=============

Install pdns-recursor software from epel repository::

 yum install pdns-recursor
 cat <<EOF >/etc/systemd/system/pdns-recursor@.service
 [Unit]
 Description=PowerDNS Recursor %i
 Documentation=man:pdns_recursor(1) man:rec_control(1)
 Documentation=https://doc.powerdns.com
 Wants=network-online.target nss-lookup.target
 Before=nss-lookup.target
 After=network-online.target
 
 [Service]
 Type=notify
 ExecStart=/usr/sbin/pdns_recursor --config-dir=/etc/pdns-recursor/%i --config-name=%i --daemon=no
 Restart=on-failure
 StartLimitInterval=0
 PrivateTmp=true
 PrivateDevices=true
 CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_SETGID CAP_SETUID CAP_CHOWN CAP_SYS_CHROOT
 NoNewPrivileges=true
 ProtectSystem=full
 ProtectHome=true
 LimitNOFILE=40000
 
 [Install]
 WantedBy=multi-user.target
 EOF
 
 rm -f /etc/pdns-recursor/recursor.conf
 
 mkdir /etc/pdns-recursor/int
 
 cat <<EOF  >/etc/pdns-recursor/int/recursor-int.conf
 allow-from=0.0.0.0/0, ::/0
 any-to-tcp=no
 client-tcp-timeout=5
 disable-packetcache=no
 dnssec=process
 dont-query=127.0.0.0/8,100.64.0.0/10,169.254.0.0/16,192.0.0.0/24,192.0.2.0/24,198.51.100.0/24,203.0.113.0/24,240.0.0.0/4,::1/128,::ffff:0:0/96,100::/64,2001:db8::/32
 entropy-source=/dev/urandom
 export-etc-hosts=no
 forward-zones-file=/etc/pdns-recursor/int/forward.zones
 latency-statistic-size=10000
 local-address=127.3.0.1
 local-port=53
 logging-facility=6
 loglevel=4
 lua-config-file=/etc/pdns-recursor/int/nta.lua
 log-common-errors=no
 max-cache-entries=8000
 max-cache-ttl=86400
 max-mthreads=2048
 max-negative-ttl=600
 max-packetcache-entries=8000
 max-qperq=50
 max-tcp-clients=300
 max-tcp-per-client=0
 max-total-msec=7000
 minimum-ttl-override=0
 network-timeout=1970
 no-shuffle=off
 packetcache-ttl=120
 packetcache-servfail-ttl=15
 pdns-distributes-queries=no
 processes=1
 query-local-address=0.0.0.0
 query-local-address6=::
 quiet=on
 root-nx-trust=off
 serve-rfc1918=on
 server-down-max-fails=64
 server-down-throttle-time=60
 server-id=rec-int
 setgid=pdns-recursor
 setuid=pdns-recursor
 single-socket=off
 spoof-nearmiss-max=20
 stack-size=200000
 stats-ringbuffer-entries=200000
 trace=off
 threads=8
 udp-truncation-threshold=1680
 version-string=PowerDNS-Recursor
 EOF

 cat <<EOF >/etc/pdns-recursor/int/forward.zones
 +example.com=127.1.0.1
 +internal.local=127.1.0.1
 EOF
 
 cat <<EOF >/etc/pdns-recursor/int/nta.lua
 addNTA('internal.local')
 addNTA('example.com')
 EOF

 systemctl enable pdns-recursor@int
 systemctl start pdns-recursor@int

And now test that you can
 * resolve public names
 * resolve the internal zone internal.local
 * resolve the internal view of example.com

dig google.de @127.3.0.1

dig internal.local @127.3.0.1

dig knx.example.com @127.3.0.1



# Monitoring Pool usage


# Background
	
	Back in 2010-2011 we started using [https://github.com/cvicente/Netdot](Netdot) but it
	was in perl, there was no cli, it was not focused enough on DNS. So <insert name after permit received>
	rewrote the need core functionallity needed for us "over the weekend" in 2011.
	
	DIM was designed in a ~10000 Person hosting company to support 100s of products with IPv4 and IPv6 Addresses
and help ~400 technical people to store and retrieve accurat technical information. If you are used to the processes
in a 10 Person company you will probably scratch your head why this is so complex.
People used to the processes in a 100000 Person company will probably just scartch their head and look for a real Tool... :-)
