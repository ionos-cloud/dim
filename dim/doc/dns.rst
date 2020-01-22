DNS
===

.. index::
   single: zone
   single: view
   single: zone view
   single: zone profile

.. _dns_concepts:

DNS Concepts
------------

Zones in **dim** are in the simplest case identical to DNS zones.

However a zone can have a different set of resource records for different
clients (for example an A record might have different values for EU and
US). Each set of resource records is called a view. All zones are created with a
view named ``default``. If a zone only has one view it is usually not necessary
to specify it.

Zone profiles are "templates" for creating new zone views. If a zone profile is
specified when creating a new zone view, the resource records (including SOA)
from the zone profile are copied to it.

Zones and zone profiles share the same namespace.


.. index::
   single: output
   single: zone group

Exporting DNS Data
------------------

An output represents a connection to a real DNS name server. The output handles
the synchronization of resource records between **dim** and the name server
(similar to AXFR/IXFR).

A zone group is a collection of zone views. Zone groups describe the mapping
between zone views and outputs. (To connect a zone view to an output, add a view
to a zone group, then add the zone group to the output.)

An output cannot receive multiple views for the same zone. This
means it's not possible to add multiple views for the same zone to a zone group
(or to multiple zone groups which share an output).


Rights
------

A normal user needs rights to perform specific actions according to the
following table:

+------------------------------------+------------------------+
|Action                              |Right                   |
+====================================+========================+
|create forward zones                |zone_create             |
+------------------------------------+------------------------+
|manage zone Z                       |zone_admin Z            |
+------------------------------------+------------------------+
|create RR in forward zone Z view V  |create_rr zone Z view V |
+------------------------------------+------------------------+
|delete RR from forward zone Z view V|delete_rr zone Z view V |
+------------------------------------+------------------------+
|create/delete RR in reverse zone Z  |(none)                  |
+------------------------------------+------------------------+

Users with the dns_admin right will be able to do all of the above. In addition
they will have access to the following actions:

+------------------------------------------------+---------------------------+
|Action                                          |Right                      |
+================================================+===========================+
|create/delete a reverse zone                    |dns_admin or network_admin |
+------------------------------------------------+---------------------------+
|create/delete a forward zone (view)/zone profile|dns_admin                  |
+------------------------------------------------+---------------------------+
|create/delete an output                         |dns_admin                  |
+------------------------------------------------+---------------------------+
|add/remove zone groups to an output             |dns_admin                  |
+------------------------------------------------+---------------------------+
|change dnssec settings for zones                |dns_admin                  |
+------------------------------------------------+---------------------------+
|grant/revoke rights for a user group            |dns_admin                  |
+------------------------------------------------+---------------------------+


DNSSEC
------

When enabling DNSSEC for a zone the following zone attributes are set:

- default_algorithm
- default_zsk_bits
- default_ksk_bits
- nsec3_algorithm (set to 0 to disable NSEC3)
- nsec3_salt
- nsec3_iterations

These default_* attributes will be used for future key rollovers.
