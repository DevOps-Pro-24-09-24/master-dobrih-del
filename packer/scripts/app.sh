#!/bin/bash
export APP_DIR="/usr/apps/flask-alb-app"
export VENV_DIR="/usr/venvs/flask-alb-app"
sudo apt-get update && sudo apt upgrade -yq
sudo apt install -yq python3-pip default-libmysqlclient-dev build-essential pkg-config git python3-venv
# sudo mkdir -p  /usr/{apps,venvs}/flask-alb-app && cd /usr/apps/flask-alb-app
sudo mkdir -p $VENV_DIR $APP_DIR && cd $APP_DIR
sudo python3 -m venv $VENV_DIR
cd /tmp && sudo curl -O https://raw.githubusercontent.com/saaverdo/flask-alb-app/refs/heads/orm/requirements.txt
pip3 install -r ./requirements.txt && rm -f ./requirements.txt
source $VENV_DIR/bin/activate
sudo chown admin:admin -R $VENV_DIR $APP_DIR
pip install -r requirements.txt

sudo cat <<EOF > fetch-ssm-params.sh
#!/bin/bash

# Отримання параметрів з AWS SSM
FLASK_CONFIG=$(aws ssm get-parameter --name "/hw5/FLASK_CONFIG" --query "Parameter.Value" --output text)
MYSQL_USER=$(aws ssm get-parameter --name "/hw5/MYSQL_USER" --query "Parameter.Value" --output text)
MYSQL_PASSWORD=$(aws ssm get-parameter --name "/hw5/MYSQL_PASSWORD" --query "Parameter.Value" --with-decryption --output text)
MYSQL_DB=$(aws ssm get-parameter --name "/hw5/MYSQL_DB" --query "Parameter.Value" --output text)
MYSQL_HOST=$(aws ssm get-parameter --name "/hw5/MYSQL_HOST" --query "Parameter.Value" --output text)
APP_DIR=$(aws ssm get-parameter --name "/hw5/APP_DIR" --query "Parameter.Value" --output text)
VENV_DIR=$(aws ssm get-parameter --name "/hw5/VENV_DIR" --query "Parameter.Value" --output text)
 
# Створення файлу зі змінними середовища
cat <<EOF > /etc/myapp.env
FLASK_CONFIG=$FLASK_CONFIG
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_DB=$MYSQL_DB
MYSQL_HOST=$MYSQL_HOST
EOF
sudo mv fetch-ssm-params.sh /usr/local/bin/fetch-ssm-params.sh
chmod +x /usr/local/bin/fetch-ssm-params.sh

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