ndcli
=====

This is ndcli, the CLI client for DIM.

installation
------------

Make sure you have the dimclient installed and then install ndcli.

```
pip install -r ./requirements.txt
pip install ./
```

There are also packages available on [github](https://github.com/1and1/dim).

configuration
-------------

You need to point ndcli to DIM. This can be done using the `-s` or `--server`
switch on every call or create a file `~/.ndclirc` with the content

```
server = https://your.server.here/dim
```
