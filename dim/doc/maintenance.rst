.. _maintenance:

=========================
Maintenance Documentation
=========================

dim maintenance includes

* monitoring the propagation of DNS Changes
* IP Space tidiying and monitoring
* DNS Domain delegation checking

If you would like to implement the checks and procedures in this
documentation you need to have setup a collectd daemon on all your servers
reporting to a central graphite. We use seyren to generate alarms if metrics
reach limits.

DNS Changes propagation
=======================

Necessary steps to monitor all stages from dim to the pdns Database on the DNS Servers.

Make sure that all zone-groups have an output
---------------------------------------------
Typically you design and setup the zone-group to output layout only once. When you think that you are done with it, verify that all zone-groups have at least on output. There is no need to check this regularly.

Checking that all zones belong to a zone-group
----------------------------------------------
Generate a list of zones that have a zone-group count of zero::

    ndcli list zones -H -L 1000000 | awk 'BEGIN { FS="\t" } ; { if ($5 == 0) print $1 }'

``ndcli list outputs -t``
-------------------------
Sample command output::

 name                      plugin          pending_records last_run            status
 pdns_cins_de_kae_bs       pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_cins_de_rhr_bap      pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_cins_us_lxa_slr      pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_cins_us_mkc_ga       pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_ins_de_kae_bs        pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_ins_de_rhr_bap       pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_ins_us_lxa_slr       pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_ins_us_mkc_ga        pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_nspa_de_kae_bs       pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_nspa_de_rhr_bap      pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_nspa_us_lxa_slr      pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_nspa_us_mkc_ga       pdns-db                       0 2016-10-06 08:43:54 OK
 pdns_sign_nspa_de_kae_bs  pdns-sign-agent               0 2016-07-14 12:14:49 OK
 pdns_sign_nspa_de_rhr_bap pdns-sign-agent               0 2016-07-14 12:14:50 OK
 pdns_sign_nspa_us_lxa_slr pdns-sign-agent               0 2016-07-14 12:14:52 OK
 pdns_sign_nspa_us_mkc_ga  pdns-sign-agent               0 2016-07-14 12:14:53 OK

I suggest to run this every 5 minutes and check that status is ``OK`` and ``pending_records`` below 200.

MySQL replication
-----------------
Run regularly ``show slave status`` on all your slave databases and look at the ``seconds_behind_master`` column. Be aware that MySQL fools you if the system has run out of space for shipping the relay logs. Running the collectd disk_free plugin on all servers is a good idea.

IP Pools
========

statics outside subnets
-----------------------
When the users rearrange subnets for pool they typically use ``ndcli modify pool <p> delete subnet <s/x> --force`` to just delete the subnet definition but to not lose the ip addresses marked as used and DNS Records referring to the ip addresses.

Of course it can happen that the above command is not followed by a smaller or larger subnet creation.

Then there are statics (used ip addresses) outside of pools. This should be avoided.

use::

  ndcli list containers | grep Static

to generate a list of leftovers. For every Static you should check whether it pings and recreate a subnet for or delete it. For this task you should have access to a bgp looking glass to make sure you do not accidentally delete a subnet defined on your routers.

IP-Pools running out of space
-----------------------------
If you have automated processes that draw IPs from dim (like OS provisioning etc) then you should monitor your pools to not run out of ip addresses.

To generate a list of pool names and their number of free addresses use::

  for p in $(ndcli list pools -H | cut -f1);
  do
   echo -n "$p: "
   ndcli list $p -H | awk 'BEGIN { FS="\\t"; sum=0}; {sum = sum + $4}; END {print sum}'
  done

To generate nice graphics of pool usage, feed the acquired data into collectd/graphite and use grafana to produce the graphics.

Validate DNS Zones
==================

check nameserver A and AAAA records
-----------------------------------

Get a list of all NS records from dim::

   ndcli list rrs \* NS -H | sort | uniq

then check that for every name an A and eventually an AAAA record exits.

You then should check that there is a DNS Server listening on those IP addresses.

Now that you have a list of listing nameserver you should check that the zone from dim is also configured on the nameserver.

You need to do a::

  ndcli list rrs some.ns. -H | cut -f2

to get a list configured with this nameserver. Then you do a::

  dig NS some.zone +trace

to see which nameservers are configured at the registry for this zone.

Following this procedure you check that the ip addresses of your nameservers are answering and that the zones configured in dim are delegated to the nameservers that are fed by dim.

check that zones on nameserver are in sync with dim
---------------------------------------------------

Haven't had problems with this for years, but it would be a good thing to check.

So the basic algorithm would be to get a list of zones from dim, get every zone from dim (with ``ndcli dump zone``) and then ``dig axfr`` the zone from every nameserver where it should reside. And then compare the axfr with the ndcli dump.

