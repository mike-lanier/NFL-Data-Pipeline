import psycopg2
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine


class PostgresDatabaseDriver:

    def __init__(self):
        load_dotenv()
        self.conn = psycopg2.connect(
            dbname=os.getenv('DB_NAME'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            host=os.getenv('DB_HOST'),
            port=os.getenv('DB_PORT')
        )
        self.cur = self.conn.cursor()
    

    def cursor(self):
        return self.cur
    

    def execute(self, query, params=None):
        try:
            self.cur.execute(query, params)
        except psycopg2.Error as e:
            print("Error executing query:", e)
            self.conn.rollback()
        

    def commit(self):
        return self.conn.commit()

    
    def close(self):
        self.cur.close()
        self.conn.close()

    def create_engine(self):
        connection_string = f"postgresql://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
        return create_engine(connection_string)