dimclient
=========

`dimclient` is a python client library to talk to dim. It provides a method
method interface to all DIM functions.

usage
-----

To use dimclient, install dimclient in your python environment.

In your script, create a new dim client and log into the instance. After that,
you can make any request.

```
import dimclient

client = dimclient.DimClient("http://localhost:8080")
# optional login
client.login('username', 'password')

# now request all IPs
ips = client.ip_list(pool="testpool")
```
