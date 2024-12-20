import os
basedir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
    HOSTNAME = os.uname()[1]
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    MYSQL_USER = os.environ.get('MYSQL_USER') or 'admin'
    MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD') or 'Pa55WD'
    MYSQL_DB = os.environ.get('MYSQL_DB') or 'flask_db'
    MYSQL_HOST = os.environ.get('MYSQL_HOST') or '127.0.0.1'
