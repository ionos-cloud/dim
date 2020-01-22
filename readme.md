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
