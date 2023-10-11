dimclient
=========

`dimclient` is a python client library to talk to dim. It provides a method
method interface to all DIM functions.

usage
-----

To use dimclient, install dimclient in your python environment.

There are two options to do that:

1. *Distribution packages:* Download and install a distribution-packaged package. There are
   packages for Debian- and Redhat-based distributions
   in dimclient specific [releases](https://github.com/1and1/dim/releases).
   Note that distribution packages install the dimclient globally.
2. *Python PIP:* There's no PyPI repo yet, but you can add a specific git tag from
   the github repo towards your requirements.txt file so PIP can download and
   install dimclient, i.e. in a virtual environment.
   A sample requirements.txt snippet is given in the following example:

```
git+https://github.com/1and1/dim.git@dimclient-1.0.1#egg=dimclient&subdirectory=dimclient
```


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
