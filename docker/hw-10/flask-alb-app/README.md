## Simple app

> Note, this app is forked by 
> https://github.com/saaverdo/flask-alb-app/tree/orm

This simple flask app is working with mysql.  
It'll show client's IP and server's hostname and write this info into mysql database.  

## Installation:
### DB settings 
DB connection parameters could be defined with environment variables (example with default values)  

`MYSQL_USER`="admin"      
`MYSQL_PASSWORD`="Pa55WD"   
`MYSQL_DB`="flask_db"     
`MYSQL_HOST`="127.0.0.1"  

#### Install DB server:

```
sudo apt update
sudo apt install -y mariadb-server
```

#### Create Mysql user and database

```
sudo mysql -e " CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'Pa55WD';
SELECT user FROM mysql.user;
create database flask_db;
grant ALL on flask_db.* to  'admin'@'%';
SHOW DATABASES;"
```

### Install app
#### install packages required for app

```
sudo apt install -y python3-pip default-libmysqlclient-dev build-essential pkg-config 
```

#### install app and dependencies

```
git clone https://github.com/saaverdo/flask-alb-app -b alb

cd flask-alb-app

sudo pip install -r requirements.txt
```

### Run app

```
gunicorn -b 0.0.0.0 app:app
```

App will be available via url `http://<instance_dns_or_ip>:8000`  

   
