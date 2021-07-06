## DIM - DNS and IP Management (and also DHCP)

DIM can be used as IP Management for a companies whole IP address space (e.g. RFC1918, public IPv4, ULA IPv6, public IPv6 (GUA), Multicast IPs, ...).

DIM can be used to manage all DNS reverse entries for all IP address space.

DIM allows to document subnets with their vlan id and gateway in a way that this information can be reused for automatic IP configuration on devices.

DIM simplifies the steps "mark ip as used, create forward record, create reverse entry, reload changed zones" to a single line in your preferred shell.

DIM provides an API to allow products to consume and return single IPv4 addresses or whole /64 or /56 prefixes for IPv6.

# Quickstart / Tutorial
Download [VM](https://github.com/1and1/dim/releases/download/vm-1.0/dim-4-0-9.qcow2) ([Documentation](VM-SETUP.md) how the VM was created). The VM is preconfigured including PowerDNS and PowerDNS recursor so that you
can immediately check whether your commands had effects.

Read [Tutorial](TUTORIAL.md) to see how DIM can be used to document Prefixes and manage DNS Records.


# Docker
not yet available. Pull requests welcome.

# Future
There is an effort going on to rewrite the middleware in go. It is planed to be a drop-in replacement.
Main Goals:
  - replace MySQL with PostgreSQL
  - do not use an ORM
  - remove properties tables, use jsonb field instead
  - put more logic in the database to avoid transfering large datasets to the application code
  - introduce generic log for all actions
  - get rid of the global lock for transaction synchronization

A link to the project will be added once the developer declares it to be ready for the public.
