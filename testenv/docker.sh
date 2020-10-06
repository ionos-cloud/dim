#!/bin/bash

sed -i /etc/sudoers -e s/Defaults.*requiretty//g

echo 'input(type="imuxsock" HostName="localhost" Socket="/dev/log")' >> /etc/rsyslog.d/devlog.conf
rsyslogd
/var/local/dim/dim-mysql.sh

pdns_server --config-name=pdns1 --config-dir=/etc/pdns >&/dev/null &
pdns_server --config-name=pdns2 --config-dir=/etc/pdns >&/dev/null &

/opt/dim/bin/manage_db init
/opt/dim/bin/manage_dim runserver --host 0.0.0.0 &
while ! bash -c 'echo > /dev/tcp/localhost/5000' 2>/dev/null; do sleep 1; done
exec /bin/bash "$@"
