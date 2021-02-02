$ ndcli create zone a.de
WARNING - Creating zone a.de without profile
WARNING - Primary NS for this Domain is now localhost.
$ ndcli create registrar-account ra plugin autodns3 url url user u password p subaccount 1
$ ndcli create registrar-account ra plugin autodns3 url url user u password p subaccount 1
ERROR - Registrar-account ra already exists
$ ndcli create registrar-account ra2 plugin autodns3 url url user u password p subaccount 1
$ ndcli modify registrar-account ra add a.de
$ ndcli modify registrar-account ra add a.de
ERROR - Zone a.de is already added to registrar-account ra
$ ndcli modify registrar-account ra2 add a.de
ERROR - Zone a.de is already added to registrar-account ra
$ ndcli modify registrar-account ra delete a.de
$ ndcli modify registrar-account ra delete a.de
ERROR - Zone a.de is not added to registrar-account ra
$ ndcli modify registrar-account ra2 add a.de
