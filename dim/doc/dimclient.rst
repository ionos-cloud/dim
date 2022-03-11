dimclient
=========

dimclient is a simple Python library implementing the :doc:`jsonrpc`. This
library is used by ndcli and it is suitable for writing Python scripts which
interact with the dim server.

Tutorial
--------

Suppose you know how to use ndcli and you want to write a script which counts
how many free IPs are left in the pools with names starting with
``MyPool``.

We first need some setup code to connect to the server and obtain a proxy object
which will forward calls to the dim server::

    from dimclient import DimClient
    client = DimClient('https://localhost/dim')
    client.login(username, password)

You can discover the API functions needed and their parameters by using the
``--debug`` (``-d``) ndcli flag::

    $ ndcli list pools MyPool* -d
    ...
    DEBUG - dim call: ippool_list({'include_subnets': True, 'pool': 'MyPool*'})
    ...
    DEBUG - dim result: [{'name': 'MyPool-12-pl', 'subnets': ['217.160.229.0/24'], 'vlan': None},
    ...

You can now just copy the function call and paste it into your script to check
if it works::

    print client.ippool_list({'include_subnets': True, 'pool': 'MyPool*'})

You can read the documentation for :func:`ippool_list`. Since we're interested
only in the list of pool names, you can set *include_subnets* to False. You can
can use keyword arguments instead of the *options* parameter to make the code
look nicer::

    for pool in client.ippool_list(pool='MyPool*', include_subnets=False):
        print pool['name']

To get the number of free ips from a pool with ndcli::

    $ ndcli list pool MyPool-13 -d
    ...
    DEBUG - dim call: ippool_get_subnets('MyPool-13', {'include_usage': True})
    ...
    DEBUG - dim result: [{'free': 254,
      'gateway': None,
      'priority': 1,
      'subnet': '1.2.3.0/24',
      'total': 256}]

Reading the documentation of :func:`ippool_get_subnets` we find out that we have
to sum the *free* fields for all the subnets to get the count of free addresses
from a pool. The final code is::

    from dimclient import DimClient
    client = DimClient('https://localhost/dim')
    free = 0
    for pool in client.ippool_list(pool='MyPool*', include_subnets=False):
        free += sum(subnet['free']
                    for subnet in client.ippool_get_subnets(pool['name'], include_usage=True))
    print free


Reference
---------

.. module:: dimclient

.. class:: DimClient(server_url, cookie_file=None)

   Instances of this class are proxies forwarding (most) method calls to the dim
   server.

   *cookie_file* is the name of a file (in libwww-perl Set-Cookie3 format) where
   cookies are read and/or written.

   .. method:: login(username, password, permanent_session=False)

      If *permanent_session* is True, a permanent cookie is requested from the
      server. This is useful for long-running scripts. The old cookie (if any)
      is ignored.

   .. attribute:: logged_in

      A boolean value indicating whether the user is logged in. This costs an
      HTTP request.

   .. method:: login_prompt(username=None, password=None, permanent_session=False, ignore_cookie=False)

      If *ignore_cookie* is ``True`` or :attr:`logged_in` is ``False``, this
      method asks for username (unless *username* is set) and password (unless
      *password* is set) and forwards them to the :meth:`login` method.

   .. method:: call(function, *args, **kwargs)

      Send the function call to the dim server and return the response or raise
      :exc:`DimError`.

      *function* must be the name of a valid function described in the
      :ref:`api`.

      Instead of passing the last argument as a dictionary (usually called
      *options*), you can use keyword arguments.

      For convenience, undefined instance attributes will return a callable
      which does the same thing as this method. The following are equivalent
      (assuming *server* is a DimClient instance)::

          server.ippool_list(pool='*')
          server.call('ippool_list', pool='*')
          server.call('ippool_list', {'pool': '*'})

      .. note:: Keyword arguments cannot be used for positional jsonrpc arguments.
