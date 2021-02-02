# create/delete container might guess the layer3domain if not provided
# cannot delete layer3domain if ipblocks exist in it
$ ndcli create layer3domain two type vrf rd 15143:1

$ ndcli create container 10.0.0.0/8
ERROR - A layer3domain is needed

$ ndcli create container 10.0.0.0/8 layer3domain default
INFO - Creating container 10.0.0.0/8 in layer3domain default

# This could work, because it is a safe guess to choose 10.0.0.0/8 layer3domain default as parent
$ ndcli create container 10.0.0.0/16
INFO - Creating container 10.0.0.0/16 in layer3domain default

$ ndcli create container 10.0.0.0/8 layer3domain two
INFO - Creating container 10.0.0.0/8 in layer3domain two

# No safe guess possible
$ ndcli create container 10.1.0.0/16
ERROR - A layer3domain is needed

$ ndcli create container 10.1.0.0/16 layer3domain two
INFO - Creating container 10.1.0.0/16 in layer3domain two

# some basic thoughts about deleting layer3domains
$ ndcli delete layer3domain three
ERROR - Layer3domain 'three' does not exist

$ ndcli delete layer3domain default
ERROR - layer3domain default still contains objects

# There is exactly one object 10.1.0.0/16 so its is safe
$ ndcli delete container 10.1.0.0/16
INFO - Deleting container 10.1.0.0/16 from layer3domain two

$ ndcli delete container 10.0.0.0/8
ERROR - A layer3domain is needed

# There is exactly one object container 10.0.0.0/16 in the database,
# so this is a safe guess
$ ndcli delete container 10.0.0.0/16
INFO - Deleting container 10.0.0.0/16 from layer3domain default

$ ndcli delete container 10.0.0.0/8 layer3domain default
INFO - Deleting container 10.0.0.0/8 from layer3domain default
$ ndcli delete container 10.0.0.0/8 layer3domain two
INFO - Deleting container 10.0.0.0/8 from layer3domain two

$ ndcli delete layer3domain two
