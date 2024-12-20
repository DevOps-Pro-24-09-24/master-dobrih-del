import os
from datetime import datetime
from config import Config
from init_db import init_db
from flask import Flask, render_template, json, request, redirect, url_for, session
from flask_bootstrap import Bootstrap
from flask_moment import Moment
from flask_mysqldb import MySQL
import MySQLdb.cursors


app = Flask(__name__)
app.config.from_object(Config)
bootstrap = Bootstrap(app)
moment = Moment(app)

mysql = MySQL(app)
init_db()

@app.route('/')
@app.route('/index')
def index():
    remote_ip = request.remote_addr if request.headers.get('X-Forwarded-For') == 'None' else request.headers.get('X-Forwarded-For')
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('INSERT INTO requests VALUES (NULL, % s, % s, %s)', (Config.HOSTNAME, request.remote_addr, str(datetime.today())))
    mysql.connection.commit()
    return render_template('index.html', hostname=Config.HOSTNAME, remote_ip=remote_ip, current_time=datetime.utcnow())

@app.route("/display")
def display():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute('SELECT * FROM requests',)
    t_data = cursor.fetchall()	
    return render_template("display.html", t_data = t_data)


@app.route("/healthcheck")
def healthcheck():
    return "ok", 200

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def page_not_found(e):
    return render_template('404.html'), 500

if __name__ == "__main__":
    app.run()
