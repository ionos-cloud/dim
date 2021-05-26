## DIM - DNS and IP Management (and also DHCP)

DIM can be used as IP Management for a companies whole IP address space (RFC1918, public IPv4, ULA IPv6 and public IPv6).

DIM can be used to manage all DNS reverse entries for all IP address space.

DIM allows to document subnets with their vlan id and gateway in a way that this information can be reused for automatic IP configuration on devices.

DIM simplifies the steps "mark ip as used, create forward record, create reverse entry, reload changed zones" to a single line in your preferred shell.

DIM provides an API to allow products to consume and return single IPv4 addresses or whole /64 or /56 prefixes for IPv6.



# What needs to be done next
* explain/advertise what DNS and IP Management (DIM) does
* rework internal documentation and publish
* automate .rpm and .deb creation for dim-client, ndcli, pdns-output and dim (/) (wip)
* rework internal testcases and add/publish (/)
* port internal automated testing to travis or something else (wip)
* rethink graphical interface of DIM
* publish internal bugs and feature requests to github issue tracker
* evaluate if there is interest for our DIM driven DHCP management

# Running dim & pdns-output in docker
The setup needs a mysql database for dim.
The pdns databases written by **pdns-output** must be initialized with the schema in `./dim/pdns.sql` (these databases are required when running `ndcli create output`)

# Configure
Set the dim mysql database details:
* for **dim** edit `dimcfg/dim.cfg` key `SQLALCHEMY_DATABASE_URI`
* for **pdns-output** edit `dimcfg/pdns-output.properties` to set the `db.` properties

# Run
Start **dim**
```bash
docker build -t dim . && docker run --name dim -d -v `pwd`/dimcfg:/etc/dim:ro dim
```
Start **pdns-output**
```bash
docker build -t dim-pdnsoutput -f Dockerfile-pdnsoutput . && docker run --name dim-pdnsoutput -v `pwd`/dimcfg:/etc/dim:ro -d dim-pdnsoutput
```
To use **ndcli**, exec into the dim docker and login with user admin (any password is fine)
```bash
docker exec -ti dim bash
$ ndcli login -u admin -p admin
```
