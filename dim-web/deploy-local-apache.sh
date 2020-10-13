#!/bin/bash
set -e

npm config set https-proxy http://proxy:3128/
npm config set proxy http://proxy:3128/
npm config set strict-ssl false

npm install

npm run build
sudo rm -rf /opt/dim-web
sudo cp -r dist /opt/dim-web

sudo cp cas.wsgi /opt/dim-web/cas.wsgi
cd cas
[ -d /opt/dim/bin ] || virtualenv /opt/dim
. /opt/dim/bin/activate
pip install pip -U
pip install -r requirements.txt

sudo systemctl restart apache2
