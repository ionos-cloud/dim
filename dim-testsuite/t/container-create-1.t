$ ndcli create container 0.0.0.0/0
 ERROR - A layer3domain is needed

$ ndcli create container 0.0.0.0/0 layer3domain default
ntainer 0.0.0.0/0 layer3domain default
INFO - Creating container 0.0.0.0/0 in layer3domain defaul

$ ndcli show container 0.0.0.0/0 layer3domain default
created:2024-06-18 11:02:43
ip:0.0.0.0/0
layer3domain:default
modified:2024-06-18 11:02:43
modified_by:admin
status:Container

$ ndcli create container 0.0.0.0/0 layer3domain default 
ERROR - 0.0.0.0/0 already exists in layer3domain default with status Container

