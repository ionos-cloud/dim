dim-testsuite
=============

This is the test suite to run tests over all the components of dim, including
ndcli, dimclient, dim itself, the output and some more.

**DO NOT USE THE TEST SUITE ON YOUR PRODUCTION DATA!**

requirements
------------

You need a running mysql instance with the following users:

```
grant all on 'pdns*'.'*' to 'pdns'@'localhost' identified by 'pdns';
grant all on 'dim'.'*' to 'dim'@'localhost' identified by 'dim';
```

and the following databases:
```
create database dim;
create database pdns1;
create database pdns2;
```

Then create the file `/etc/dim/dim.cfg` with a production like configuration.
It must contain the database credentials, so that the server can connect to the
database.

The following programs need to be installed:

* python3
* colordiff

how to run the test suite?
--------------------------

To run the test suite, make sure the mysql database is up and running.

Then call `make`.
It will proceed and build a virtual environment and install the tools needed
into it.

After that it will start the dim server and start making ndcli calls against
the server.

To control the location of the virtual environment or the output directory,
use the variables `VDIR` and `ODIR`.

```
make VDIR=/tmp/venv ODIR=/tmp/test_output
```

If you want to skip the database initialization or installing of dependencies,
let make run the tests directly by using `make test`.
