#!/bin/bash
# Local setup for Debian stretch

set -e

DIM=$HOME/dev/dim/dim

# pdns
sudo mkdir -p /etc/pdns/
sudo cp $DIM/testenv/etc/pdns/pdns-pdns1.conf /etc/pdns/
sudo cp $DIM/testenv/etc/pdns/pdns-pdns2.conf /etc/pdns/

# dim-* services
sudo ln -snf $DIM/testenv /var/local/dim
sudo ln -sf /var/local/dim/*.service /etc/systemd/system/
sudo systemctl start dim-mysql dim-pdns1 dim-pdns2

# dim
sudo ln -sf $HOME/.virtualenvs/dim/bin/manage_dim /opt/dim/bin/manage_dim
sudo ln -sf $HOME/.virtualenvs/dim/bin/manage_db /opt/dim/bin/manage_db
