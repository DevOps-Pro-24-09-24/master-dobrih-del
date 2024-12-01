#!/bin/bash
export APP_DIR="/usr/apps/flask-alb-app"
export VENV_DIR="/usr/venvs/flask-alb-app"
sudo apt-get update && sudo apt upgrade -yq
sudo apt install -yq python3-pip default-libmysqlclient-dev build-essential pkg-config git python3-venv
# sudo mkdir -p  /usr/{apps,venvs}/flask-alb-app && cd /usr/apps/flask-alb-app
sudo mkdir -p $VENV_DIR $APP_DIR && cd $APP_DIR
sudo python3 -m venv $VENV_DIR
sudo git clone https://github.com/saaverdo/flask-alb-app -b orm ./
source $VENV_DIR/bin/activate
sudo chown admin:admin -R $VENV_DIR $APP_DIR
pip install -r requirements.txt

# sudo cat <<EOF > .flaskenv
# FLASK_APP=appy.py
# "PATH=$VENV_DIR/bin"
# MYSQL_USER="flask_user"
# MYSQL_PASSWORD="rfvbnmkijuhgfdsdfgvb"
# MYSQL_DB="flask_db0"
# MYSQL_HOST="192.168.0.137"
# EOF

# export MYSQL_USER="flask_user"
# export MYSQL_PASSWORD="rfvbnmkijuhgfdsdfgvb"
# export MYSQL_DB="flask_db0"
# export MYSQL_HOST="192.168.0.137"
# export FLASK_CONFIG=mysql

# FLASK_CONFIG=mysql MYSQL_USER="flask_user" MYSQL_PASSWORD="rfvbnmkijuhgfdsdfgvb" MYSQL_DB="flask_db0" MYSQL_HOST="192.168.0.137" $VENV_DIR/bin/gunicorn  --bind 0.0.0.0:8080 appy:app
# $VENV_DIR/bin/gunicorn  --bind 0.0.0.0:8080 appy:app

sudo cat <<EOF > gunicorn.service
[Unit]
Description=Gunicorn instance to serve application
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=$APP_DIR
Environment="FLASK_CONFIG=mysql"
Environment="PATH=$VENV_DIR/bin"
Environment=MYSQL_USER="flask_user"
Environment=MYSQL_PASSWORD="rfvbnmkijuhgfdsdfgvb"
Environment=MYSQL_DB="flask_db0"
Environment=MYSQL_HOST="192.168.0.137"
ExecStart=$VENV_DIR/bin/gunicorn  --bind 0.0.0.0:8080 appy:app
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

sudo mv gunicorn.service /etc/systemd/system/gunicorn.service
sudo systemctl daemon-reload
sudo systemctl restart gunicorn.service