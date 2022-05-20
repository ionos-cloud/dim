$ ndcli login -u withperm -p p
$ ndcli login -u withoutperm -p p
$ ndcli login -u networkadmin -p p
$ ndcli create pool testpool
$ ndcli modify pool testpool set attrs 'donottouch:true'
$ ndcli create user-group withperm
$ ndcli modify user-group withperm add user withperm
$ ndcli modify user-group withperm grant attr 'withperm.' testpool
$ ndcli create user-group withoutperm
$ ndcli modify user-group withoutperm add user withoutperm
$ ndcli create user-group networkadmin
$ ndcli modify user-group networkadmin add user networkadmin
$ ndcli modify user-group networkadmin grant network_admin

$ ndcli modify pool testpool set attrs 'withperm.success:true' -u withperm
$ ndcli show pool testpool -u withperm
created:2022-05-11 16:49:06
donottouch:true
layer3domain:default
modified:2022-05-11 16:49:07
modified_by:withperm
name:testpool
withperm.success:true
$ ndcli modify pool testpool set attrs 'donottouch:false' -u withperm
ERROR - Permission denied (can_set_attribute testpool donottouch)
$ ndcli modify user-group withperm grant attr 'fromnetworkadmin.' testpool -u networkadmin
$ ndcli modify pool testpool set attrs 'fromnetworkadmin.success:true' -u withperm
$ ndcli show pool testpool -u withperm
created:2022-05-11 16:49:06
donottouch:true
fromnetworkadmin.success:true
layer3domain:default
modified:2022-05-11 16:49:07
modified_by:withperm
name:testpool
withperm.success:true
$ ndcli modify pool testpool set attrs 'thisfails:does it?' -u withoutperm
ERROR - Permission denied (can_set_attribute testpool thisfails)
$ ndcli list pools -a name,withperm.success
name withperm.success
testpool true
