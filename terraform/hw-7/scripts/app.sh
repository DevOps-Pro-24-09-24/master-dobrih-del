#!/bin/bash
echo "Start!" > /var/log/init_script.log
export APP_DIR="/usr/apps/flask-alb-app"
export VENV_DIR="/usr/venvs/flask-alb-app"
sudo apt-get update && sudo apt upgrade -yq
sudo apt install -yq nginx python3-certbot-nginx python3-pip default-libmysqlclient-dev build-essential pkg-config git python3-venv
# sudo mkdir -p  /usr/{apps,venvs}/flask-alb-app && cd /usr/apps/flask-alb-app
sudo mkdir -p $VENV_DIR $APP_DIR && cd $APP_DIR
sudo python3 -m venv $VENV_DIR
sudo git clone https://github.com/saaverdo/flask-alb-app -b orm ./
source $VENV_DIR/bin/activate
sudo chown admin:admin -R $VENV_DIR $APP_DIR
pip install -r requirements.txt

RDS_ENDPOINT=$(aws ssm get-parameter --name "/rds/endpoint" --query "Parameter.Value" --output text)
RDS_HOST=$(echo $RDS_ENDPOINT | cut -d':' -f1)
RDS_PORT=$(echo $RDS_ENDPOINT | cut -d':' -f2)
echo "$RDS_HOST hw7-rds-endpoint" >> /etc/hosts


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
Environment=MYSQL_USER="db_user"
Environment=MYSQL_PASSWORD="db_password"
Environment=MYSQL_DB="db_name1"
Environment=MYSQL_HOST="$RDS_HOST"
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
sudo systemctl enable --now gunicorn.service
sudo systemctl restart gunicorn.service

MY_IP=$(curl -s curl http://169.254.169.254/latest/meta-data/public-ipv4)
MY_DOMAIN="$MY_IP.sslip.io"
sudo cat <<EOF > /etc/nginx/sites-enabled/flask
server {

    server_name $MY_DOMAIN;
    listen 80;

    location / {
        proxy_pass http://127.1:8080;
        proxy_set_header Host \$http_host;
        proxy_redirect off;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        real_ip_header X-Real-IP;

        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
rm -f /etc/nginx/sites-enabled/default;
nginx -t && nginx -s reload;
certbot --nginx  -d "$MY_DOMAIN" --agree-tos --register-unsafely-without-email;
echo "END!" >> /var/log/init_script.log