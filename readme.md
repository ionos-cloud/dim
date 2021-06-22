## DIM - DNS and IP Management (and also DHCP)

DIM can be used as IP Management for a companies whole IP address space (e.g. RFC1918, public IPv4, ULA IPv6, public IPv6 (GUA), Multicast IPs, ...).

DIM can be used to manage all DNS reverse entries for all IP address space.

DIM allows to document subnets with their vlan id and gateway in a way that this information can be reused for automatic IP configuration on devices.

DIM simplifies the steps "mark ip as used, create forward record, create reverse entry, reload changed zones" to a single line in your preferred shell.

DIM provides an API to allow products to consume and return single IPv4 addresses or whole /64 or /56 prefixes for IPv6.

# Quickstart
Please read [Quickstart](QUICKSTART.md).

# Docker
not yet available
