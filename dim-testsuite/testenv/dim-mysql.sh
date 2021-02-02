#!/bin/bash

MYSQL_DIR=/dev/shm/mysql

pkill -f $MYSQL_DIR
rm -rf $MYSQL_DIR
mkdir -p $MYSQL_DIR
mysql_install_db --user=mysql --datadir=$MYSQL_DIR >&/dev/null
mysqld_safe --basedir=/usr --datadir=$MYSQL_DIR --tmpdir=$MYSQL_DIR --pid-file=$MYSQL_DIR/mysqld.pid --socket=$MYSQL_DIR/mysql.sock --user=mysql --port=3307 </dev/null >&/dev/null &
mysqladmin --socket=$MYSQL_DIR/mysql.sock --wait=1 -u root password ''

# create databases
MYSQL="mysql -uroot --socket=$MYSQL_DIR/mysql.sock"
echo "create database dim; grant all privileges on dim.* to dim@localhost identified by 'dim';" | $MYSQL
echo "create database pdns1; grant all privileges on pdns1.* to pdns@localhost identified by 'pdns';" | $MYSQL
echo "create database pdns2; grant all privileges on pdns2.* to pdns@localhost identified by 'pdns';" | $MYSQL
$MYSQL pdns1 < /var/local/dim/pdns.sql
$MYSQL pdns2 < /var/local/dim/pdns.sql
