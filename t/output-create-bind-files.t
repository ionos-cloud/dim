# This is a bit misleading. The bind files shall be written by
# an agent, running on the bind nameserver itself
#
# It is run from cron.
#
# An authenticated dim user is needed.
#
# I think everything can be put on the commandline
#

# ./dim-bind-file-agent
# 
# -d --debug
# -v --verbose
# -h -? --help
# -V --version
#
# -f --facility (defaults to LOCAL0)
# 
# -s --server (DIM Server url)
#
# -o --output (This is an output in the sense of ndcli create output)
# -z --zonefiledir
# -i --includefile
# 
# -u --user
# -p --password

# Zonefiles created by the agent have a modification time of
# the views modification time
#
# Logging is done through syslog 
#
# -o it is ok if -o can only be once on the commandline,
# if you happen to need more than on output on one bind server
# enter multiple ./dim-bind-file-agent into your crontab.
#
# The ./dim-bind-file-agent should come as a separate .deb
# package.
