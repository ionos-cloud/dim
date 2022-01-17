=======
 ndcli
=======

Configuration
=============

ndcli reads "key=value" pairs from ``~/.ndclirc``. An example::

    server   = https://localhost/dim
    username = admin
    layer3domain = default

The recognized keys are:

server
    The Dim server to contact. Defaults to https://localhost/dim.

username
    The Dim user name (used for authentication). Defaults to the name of the current user.

layer3domain
    The layer3domain must be set with every request when more than one layer3domain is used.
    By setting it in the config it will be used as the default layer3domain.
    The default layer3domain is ``default``.

Environment Variables
=====================

It is possible to control ndcli with environment variables. With these the settings
from the configuration file can be overwritten. The following settings are supported:

NDCLI_CONFIG
    Set the path to a specific ndclirc path (default: ``~/.ndclirc``)

NDCLI_COOKIEPATH
    This setting controls which cookie file should be used. When it does not
    contain a session matching the server, a login will be required.
    (default ``~/.ndcli.cookie.{username}``)

NDCLI_LAYER3DOMAIN
    Set the layer3domain to use as the new default value.

NDCLI_SERVER
    Set the dim server URL. When this is not set, the value from the config
    will be used.

NDCLI_USERNAME
    Set the username that ndcli should use. By default the system username will
    be used.

Login
=====

ndcli stores the HTTP cookie received from the Dim server in
``~/.ndcli.cookie.<username>``. A future run will use the cookie from this file if it's
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
