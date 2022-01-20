# Create a user with network_admin rights and two regular users
# make sure the users exist
# as user usera
$ ndcli login -u usera -p p
# as user userb
$ ndcli login -u userb -p p
# as user network
$ ndcli login -u network -p p

# as user admin
$ ndcli create user-group groupa
$ ndcli modify user-group groupa add user usera

$ ndcli create user-group groupb
$ ndcli modify user-group groupb add user userb

$ ndcli create pool testpool
$ ndcli create container 12.0.0.0/8
INFO - Creating container 12.0.0.0/8 in layer3domain default
$ ndcli modify pool testpool add subnet 12.0.0.0/24
INFO - Created subnet 12.0.0.0/24 in layer3domain default
WARNING - Creating zone 0.0.12.in-addr.arpa without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify user-group groupa grant allocate testpool

$ ndcli create zone test.zone
WARNING - Creating zone test.zone without profile
WARNING - Primary NS for this Domain is now localhost.

$ ndcli modify user-group groupa grant create_rr test.zone
$ ndcli modify user-group groupa grant delete_rr test.zone

$ ndcli modify user-group groupb grant create_rr test.zone
$ ndcli modify user-group groupb grant delete_rr test.zone

# as user usera
$ ndcli create rr os.test.zone. a 13.0.0.1 -u usera
INFO - Marked IP 13.0.0.1 from layer3domain default as static
INFO - Creating RR os A 13.0.0.1 in zone test.zone
INFO - No zone found for 1.0.0.13.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

$ ndcli create rr a.test.zone. a 12.0.0.1 -u usera
INFO - Marked IP 12.0.0.1 from layer3domain default as static
INFO - Creating RR a A 12.0.0.1 in zone test.zone
INFO - Creating RR 1 PTR a.test.zone. in zone 0.0.12.in-addr.arpa


# userb delete possible "in outer space"
# as user userb
$ ndcli delete rr os.test.zone. -u userb
INFO - Deleting RR os A 13.0.0.1 from zone test.zone
INFO - Freeing IP 13.0.0.1 from layer3domain default

# userb delete not possible with delete rr fwd 
$ ndcli delete rr a.test.zone. -u userb
ERROR - Permission denied (can_allocate testpool)

# userb delete not possible with delete rr rev 
$ ndcli modify zone 0\.0\.12\.in-addr\.arpa delete rr 1 -u userb
ERROR - Permission denied (can_allocate testpool)

$ ndcli create rr os.test.zone. a 13.0.0.1 -u userb
INFO - Marked IP 13.0.0.1 from layer3domain default as static
INFO - Creating RR os A 13.0.0.1 in zone test.zone
INFO - No zone found for 1.0.0.13.in-addr.arpa.
WARNING - No reverse zone found. Only creating forward entry.

# make sure usera still can do things

$ ndcli login -u usera -p p
# as user usera
$ ndcli delete rr os.test.zone. -u usera
INFO - Deleting RR os A 13.0.0.1 from zone test.zone
INFO - Freeing IP 13.0.0.1 from layer3domain default

# maybe also change behavior to delete forward record (not now)
$ ndcli modify zone 0\.0\.12\.in-addr\.arpa delete rr 1 -u usera
INFO - Deleting RR 1 PTR a.test.zone. from zone 0.0.12.in-addr.arpa

$ ndcli create rr a.test.zone. a 12.0.0.1 -u usera
INFO - a.test.zone. A 12.0.0.1 already exists
INFO - Creating RR 1 PTR a.test.zone. in zone 0.0.12.in-addr.arpa

$ ndcli delete rr a.test.zone. -u usera
INFO - Deleting RR a A 12.0.0.1 from zone test.zone
INFO - Deleting RR 1 PTR a.test.zone. from zone 0.0.12.in-addr.arpa
INFO - Freeing IP 12.0.0.1 from layer3domain default

# Back to admin and clean up
# as user admin
$ ndcli delete user-group groupa
$ ndcli delete user-group groupb
$ ndcli modify pool testpool remove subnet 12.0.0.0/24 -c -f -q
$ ndcli delete pool testpool 
$ ndcli delete container 12.0.0.0/8
INFO - Deleting container 12.0.0.0/8 from layer3domain default
