dim-testsuite
=============

This is the test suite to run tests over all the components of dim, including
ndcli, dimclient, dim itself, the output and some more.

**DO NOT USE THE TEST SUITE ON YOUR PRODUCTION DATA!**

As of now, make sure that your home *does not* contain a vaild `.ndclirc` and `.ndcli.cookie`.
If ndcli finds valid login information these might get use. In consequence the tests will be
run on the production DIM.

requirements
------------

You need a running mysql instance listening on 127.0.0.1:3307 with the following databases:

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

You also need to grant the user running the tests full rights on the databases:
```
create user 'janedoe'@'localhost';
grant all on pdns1.* to 'janedoe'@'localhost';
grant all on pdns2.* to 'janedoe'@'localhost';
grant all on dim.* to 'janedoe'@'localhost';
```

If MariaDB does not startup please try to disable SELinux and try again.

The database files should be on a tmpfs to have a bit better performance for testing.

Then create the file `/etc/dim/dim.cfg` with a production like configuration.
It must contain the database credentials, so that the server can connect to the
database.

The following programs need to be installed:

* python3-devel
* colordiff
* make
* mariadb-devel
* openldap-devel
* gcc

how to run the test suite?
--------------------------

To run the test suite, make sure the mysql database is up and running.

Then call `make`.
It will proceed and build a virtual environment and install the tools needed
into it.

After that it will start the dim server and start making ndcli calls against
the server.

To control the location of the virtual environment, the output directory, or
the log directory, use the variables `VDIR`, `ODIR` and `LDIR`.

```
make VDIR=/tmp/venv ODIR=/tmp/test_output LDIR=/tmp/test_logs
```

If you want to skip the database initialization or installing of dependencies,
let *make* run the tests directly by using `make test`.

To run only specific testfiles, use the variable `TEST` for `make test` after
you've created the virtual environment.

```
make test TESTS="<test1> <test2>"
```

`runtest.py` will look in the t directory for the specific testcases and run
only the ones specified in `TESTS`. After the case was run, your dim environment will have
exactly the state it broke in, so you can poke into it with ndcli, for example:

```
$VDIR/bin/ndcli list pools
```
