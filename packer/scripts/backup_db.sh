#!/bin/bash
source /etc/myapp.env
time=$(date +%H%M_%d.%m.%y)
backup_file="$(mktemp -d)/$MYSQL_DB_$time.sql.gz"
s3_bucket=$(aws ssm get-parameter --name "/hw5/BACKUP_BUCKET" --query "Parameter.Value" --output text)
# ищем mysqldump, если нет, то устанавливаем
binpath=$(which mysqldump)
[ -f "$binpath" ] || (sudo apt update &&  sudo apt install -y mariadb-client) && echo "$binpath exist"
# Создание бэкапа базы данных
mysqldump -u app_user -p"$MYSQL_PASSWORD" app_db | gzip > $backup_file

# Загрузка бэкапа в S3
aws s3 cp $backup_file s3://$s3_bucket/

# Удаление старых бэкапов из S3, оставляя только последние 7 копий
aws s3 ls s3://$s3_bucket/ | grep "$MYSQL_DB" | sort | head -n -7 | awk '{print $4}' | while read -r file; do
  aws s3 rm s3://$s3_bucket/"$file"
done

# Удаление старых локальных бэкапов
find /tmp -name "$MYSQL_DB_*.sql.gz" -mtime +7 -delete