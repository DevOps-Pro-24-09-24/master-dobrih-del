#!/bin/bash
MYSQL_USER=flask_user
MYSQL_PASSWORD=rfvbnmkijuhgfdsdfgvb
MYSQL_DB=flask_db0
APP_DIR="/usr/apps/flask-alb-app"
VENV_DIR="/usr/venvs/flask-alb-app"
MYSQL_HOST=$(aws ec2 describe-instances --filters "Name=tag:DZ,Values=hw5" "Name=tag:Name,Values=DB" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text | cat)
aws ssm put-parameter --name "/hw5/MYSQL_HOST" --value "$MYSQL_HOST" --type "String" --overwrite
aws ssm put-parameter --name "/hw5/MYSQL_USER" --value "$MYSQL_USER" --type "String" --overwrite
aws ssm put-parameter --name "/hw5/MYSQL_PASSWORD" --value "$MYSQL_PASSWORD" --type "String" --overwrite
aws ssm put-parameter --name "/hw5/MYSQL_DB" --value "$MYSQL_DB" --type "String" --overwrite
aws ssm put-parameter --name "/hw5/APP_DIR" --value "$APP_DIR" --type "String" --overwrite
aws ssm put-parameter --name "/hw5/VENV_DIR" --value "$VENV_DIR" --type "String" --overwrite
aws ssm put-parameter --name "/hw5/BACKUP_BUCKET" --value "hw5-mysql-backup" --type "String" --overwrite

