#!/bin/bash

# Отримання параметрів з AWS SSM
# FLASK_CONFIG=$(aws ssm get-parameter --name "/hw5/FLASK_CONFIG" --query "Parameter.Value" --output text)
MYSQL_USER=$(aws ssm get-parameter --name "/hw5/MYSQL_USER" --query "Parameter.Value" --output text)
MYSQL_PASSWORD=$(aws ssm get-parameter --name "/hw5/MYSQL_PASSWORD" --query "Parameter.Value" --with-decryption --output text)
MYSQL_DB=$(aws ssm get-parameter --name "/hw5/MYSQL_DB" --query "Parameter.Value" --output text)
MYSQL_HOST=$(aws ssm get-parameter --name "/hw5/MYSQL_HOST" --query "Parameter.Value" --output text)
APP_DIR=$(aws ssm get-parameter --name "/hw5/APP_DIR" --query "Parameter.Value" --output text)
VENV_DIR=$(aws ssm get-parameter --name "/hw5/VENV_DIR" --query "Parameter.Value" --output text)
BACKUP_BUCKET=$(aws ssm get-parameter --name "/hw5/BACKUP_BUCKET" --query "Parameter.Value" --output text)

# Створення файлу зі змінними середовища
cat <<EOF > /etc/myapp.env
FLASK_CONFIG=$FLASK_CONFIG
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD
MYSQL_DB=$MYSQL_DB
MYSQL_HOST=$MYSQL_HOST
BACKUP_BUCKET=$BACKUP_BUCKET
EOF
