=======
 ndcli
=======

Configuration
=============

ndcli reads "key=value" pairs from ``~/.ndclirc``. An example::

    server   = https://localhost/dim
    username = admin

The recognized keys are:

server
    The Dim server to contact. Defaults to https://localhost/dim.

username
    The Dim user name (used for authentication). Defaults to the name of the current user.

Login
=====

ndcli stores the HTTP cookie received from the Dim server in
``~/.ndcli.cookie``. A future run will use the cookie from this file if it's
still valid (to avoid asking for username/password). However, if you wish to
force re-authentication, you can delete the file.

Output
======

The normal output is written to stdout. The program may also output messages to
stderr. The verbosity of the messages can be controlled using ``-v``, ``-d`` or
``-q``.

When the server is overloaded, the operations that change data on the server may
fail with the message::

    ERROR - Lock timeout

If this happens, you can safely retry the command later. If the error persists,
please contact the administrator.


.. include:: gendoc.txt
