#!/bin/bash
export APP_DIR="/usr/apps/flask-alb-app"
export VENV_DIR="/usr/venvs/flask-alb-app"
sudo apt-get update && sudo apt upgrade -yq
sudo apt install -yq python3-pip cron default-libmysqlclient-dev build-essential pkg-config git python3-venv
# sudo mkdir -p  /usr/{apps,venvs}/flask-alb-app && cd /usr/apps/flask-alb-app
sudo mkdir -p $VENV_DIR $APP_DIR && cd $APP_DIR
sudo python3 -m venv $VENV_DIR
cd /tmp && sudo curl -O https://raw.githubusercontent.com/saaverdo/flask-alb-app/refs/heads/orm/requirements.txt
pip3 install -r ./requirements.txt && rm -f ./requirements.txt
source $VENV_DIR/bin/activate
sudo chown admin:admin -R $VENV_DIR $APP_DIR
pip install -r requirements.txt

sudo cat <<EOF > gunicorn.service
[Unit]
Description=Gunicorn instance to serve application
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=$APP_DIR
ExecStartPre=/usr/local/bin/fetch-ssm-params.sh
EnvironmentFile=/etc/myapp.env
ExecStart=$VENV_DIR/bin/gunicorn --bind 0.0.0.0:8080 appy:app
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

sudo mv gunicorn.service /etc/systemd/system/gunicorn.service
sudo systemctl daemon-reload
sudo systemctl enable gunicorn.service