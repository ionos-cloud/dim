# Because I now have some 10s of DIM Servers running
# I'd like to have a command that shows me which server
# I'm using.
#
# I know, I could look into .ndclirc 
#
# $ ndcli show server-info
# version: 2.0b01
# host: ac1dimmw01
# os: Linux x86_64 #1 SMP Debian 3.2.41-2~bpo60+1
# db: mysql://172.20.36.49/netdot
# python: 2.6.4

# The values for version, host, os and python are automatically guessed
# version is the debian package version number
# host is uname -n
# os is `uname` `uname -m` `uname -v`
#
# db is SQLALCHEMY_DATABASE_URI but withouth user/password (possible?)
#
# All variables in /etc/dim/dim.cfg with the prefix SERVER_INFO_ are
# also displayed. If there is a 
#
# SERVER_INFO_ENVIRONMENT=live
#
# in the cfg file then the above server info also has a
#
# enviroment: live 
#
# in the output of show server-info
