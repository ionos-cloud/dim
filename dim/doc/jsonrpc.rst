JSON-RPC Interface
==================

.. _authentication:

Authentication
--------------

The examples from this section assume that the dim server URL is
``http://example.com/dim``.

To access the JSON-RPC interface you must provide a valid session
cookie. Failure to do so will result in a 403 HTTP response.

To get a session cookie, a HTTP POST request must be sent to ``/login``
with the following parameters:

- username
- password

Example::

    POST /dim/login HTTP/1.1
    Host: example.com
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 35

    username=username&password=password

A cookie will be set in the response::

    Set-Cookie: Apache2::SiteControl_Netdot=55ef6879eabe31d4b9f8f4f121c9b454; expires=Thu, 22 Dec 2011 13:39:15 GMT; path=/dim/


Tools
~~~~~

Tools that authenticate users and want to call DIM on behalf of them need to do a HTTP POST request to ``/login``
with the following parameters:

- username
- tool: the tool name
- salt
- sign: md5(username + salt + secret_key) where secret_key is the shared secret between DIM and the tool

Example ::


    POST /dim/login HTTP/1.1
    Host: example.com
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 85

    username=username&tool=toolname&salt=1394100619&sign=d0b0b73f15734c93a16c158dd1f14f55


where the shared secret is ``secretkey``.


CAS
~~~

For `CAS_` login, the frontend uses the ``/cas`` endpoint to check the ticket and generate the
necessary cookie.

.. _CAS: https://apereo.github.io/cas


Protocol
--------

The protocol used is `JSON-RPC 2.0`_. Requests must be sent to ``/jsonrpc``.

.. _JSON-RPC 2.0: http://www.jsonrpc.org/spec.html

Example request for the call ``ipblock_get_attrs("12.0.0.1")``::

    POST /dim/jsonrpc HTTP/1.1
    Host: example.com
    Content-Type: application/json-rpc; charset=utf-8
    Cookie: Apache2::SiteControl_Netdot=55ef6879eabe31d4b9f8f4f121c9b454
    Content-Length: 78

    {"jsonrpc":"2.0","id":null,"method":"ipblock_get_attrs","params":["12.0.0.1"]}

Response::

    HTTP/1.1 200 OK
    Content-Type: application/json-rpc; charset=utf-8
    Content-Length: 75

    {"jsonrpc":"2.0","id":null,"result":{"status":"Available","ip":"12.0.0.1"}}

Another example for a call that returns an error:

- JSON request: ``{"jsonrpc":"2.0","id":null,"method":"ipblock_get_attrs","params":["12.0.0.1a"]}``
- JSON response: ``{"jsonrpc":"2.0","error":{"message":"Invalid IP address: '12.0.0.1a'","code":1},"id":null}``
