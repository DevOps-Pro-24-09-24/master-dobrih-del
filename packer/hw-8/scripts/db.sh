#!/bin/bash
sudo apt-get update
sudo apt upgrade -yq
sudo apt-get install -yq mariadb-server

sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

# sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY '!@pass()_111';"
sudo mysql -uroot -ppassword  <<EOF
CREATE USER 'flask_user'@'%' IDENTIFIED BY 'rfvbnmkijuhgfdsdfgvb';
CREATE DATABASE flask_db0;
GRANT ALL PRIVILEGES ON flask_db0.* TO 'flask_user'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
sudo systemctl restart mysql
sudo systemctl enable --now mysql