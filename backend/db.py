import os
import sqlite3

DATABASE = '/opt/clustercreator/database.db' 

class DatabaseManager:
    def __init__(self):
        if not os.path.exists(DATABASE):
            self.__create__()

    def __create__(self):
        conn = sqlite3.connect(DATABASE)
        with conn:
            cursor = conn.cursor()
            cursor.execute(f"""
                CREATE TABLE IF NOT EXISTS environments (
                    env TEXT PRIMARY KEY,
                    correo TEXT,
                    nombre TEXT,
                    tipo TEXT,
                    nodos INTEGER,
                    pid INTEGER,
                    url TEXT
                )
            """)

    def select(self, condition, parameters=()):
        query = f"SELECT * FROM environments WHERE {condition}"
        conn = sqlite3.connect(DATABASE)
        with conn:
            cursor = conn.execute(query, parameters)
            result = cursor.fetchall()
        
        column_names = [description[0] for description in cursor.description]
        result_list = []
        for row in result:
            row_dict = {column: value for column, value in zip(column_names, row)}
            result_list.append(row_dict)
        
        return result_list

    def create_environment(self, env, correo, nombre, tipo, nodos, pid):
        insert = f"INSERT INTO environments (env, correo, nombre, tipo, nodos, pid) VALUES (?, ?, ?, ?, ?, ?)"
        conn = sqlite3.connect(DATABASE)
        with conn:
            conn.execute(insert, (env, correo, nombre, tipo, nodos, pid))
            conn.commit()

    def all_environments(self):
        return self.select("1=1")

    def get_environment(self, env):
        environments = self.select("env=?", (env,))
        if len(environments) is 1:
            return environments[0]
        else:
            return None

    def delete_environment(self, env):
        conn = sqlite3.connect(DATABASE)
        with conn:
            conn.execute(f"DELETE FROM environments WHERE env=?", (env,))

    def update_url_environment(self, env, url):
        update = f"UPDATE environments SET url = ? WHERE env = ?"
        conn = sqlite3.connect(DATABASE)
        with conn:
            conn.execute(update, (url, env))
            conn.commit()
