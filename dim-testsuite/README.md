dim-testsuite
=============

This is the test suite to run tests over all the components of dim, including
ndcli, dimclient, dim itself, the output and some more.

**DO NOT USE THE TEST SUITE ON YOUR PRODUCTION DATA!**

requirements
------------

You need a running mysql instance with the following databases:

```
create database dim;
create database pdns1;
create database pdns2;
```

and the following users:
```
grant all on pdns1.* to 'pdns'@'localhost' identified by 'pdns';
grant all on pdns2.* to 'pdns'@'localhost' identified by 'pdns';
grant all on dim.* to 'dim'@'localhost' identified by 'dim';
```

Then create the file `/etc/dim/dim.cfg` with a production like configuration.
It must contain the database credentials, so that the server can connect to the
database.

The following programs need to be installed:

* python3-devel
* colordiff
* make
* mariadb-devel
* openldap-devel

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
let *make* run the tests directly by using `make test`.

To run a single testfile, use the following command after you have created the
virtual environment:

```
export VDIR=/tmp/venv
export ODIR=/tmp/test_output
make VDIR=$VDIR ODIR=$ODIR
PATH="$VDIR/bin:$PATH" TEST_OUTPUT_DIR=$ODIR $VIDR/bin/python ./runtest.py -d <testfile>
```

`runtest.py` will look in the t directory for the specific testcase and run
only that single one. After the case was run, your dim environment will have
exactly the state it broke in, so you can poke into it with ndcli, for example:

```
$VDIR/bin/ndcli list pools
```

where is the log?
-----------------

Currently dim is started via the runtest.py in a background process. If this is
not enough for your use case, you can start dim yourself with the same config
file.
runtest.py will still work and all tests will still be done.
