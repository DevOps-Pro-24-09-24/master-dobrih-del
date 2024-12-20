from config import Config
import pymysql


def init_db(): 
    connection = pymysql.connect(host=Config.MYSQL_HOST, 
                        user=Config.MYSQL_USER, 
                        password=Config.MYSQL_PASSWORD, 
                        database=Config.MYSQL_DB)

    with connection:
        cursor = connection.cursor()
        with open('schema.sql') as f:
            cursor.execute(f.read())
        connection.commit()
