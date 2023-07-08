from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import os
import sqlite3
import subprocess

app = Flask(__name__, static_folder='static')
CORS(app)

DATABASE = '/opt/clustercreator/database.db' 
FILE_PATH_PREFIX = '/opt/clustercreator/config'
CREATE_COMMAND= '/opt/clustercreator/cmd/create-environment.sh'
DESTROY_COMMAND= '/opt/clustercreator/cmd/destroy-environment.sh'

@app.route('/')
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def home(path):
    if path != '':
        # Envía el archivo solicitado desde la carpeta estática
        return send_from_directory(app.static_folder, path)
    else:
        # Si la ruta está vacía, devuelve el archivo "index.html"
        return send_from_directory(app.static_folder, 'index.html')

@app.route('/create')
def create_environment():
    env = request.args.get('env')
    correo = request.args.get('correo')
    nombre = request.args.get('nombre')
    tipo = request.args.get('tipo')
    nodos = int(request.args.get('nodos'))

    # Verificar si ya existe un registro con el mismo env
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM environments WHERE env=?", (env,))
    row = cursor.fetchone()

    if row is not None:
        conn.close()
        error_response = {
            'error': f"Ya existe un registro para el entorno '{env}'."
        }
        return jsonify(error_response), 400

    # Insertar el nuevo registro en la tabla environments
    cursor.execute(f"INSERT INTO environments (env, correo, nombre, tipo, nodos) VALUES (?, ?, ?, ?, ?)",
                   (env, correo, nombre, tipo, nodos))
    conn.commit()
    conn.close()

    # Ejecutar el proceso Bash en segundo plano
    subprocess.Popen([CREATE_COMMAND, env, nodos])

    response = {
        'message': 'Creación del entorno Iniciado.'
    }
    return jsonify(response)

@app.route('/destroy')
def destroy_environment():
    env = request.args.get('env')  # Obtener el parámetro 'env' de la URL

    # Verificar si existe una entrada para el entorno en la base de datos
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM environments WHERE env=?", (env,))
    row = cursor.fetchone()

    if row is None:
        conn.close()
        error_response = {
            'error': f"No existe entorno '{env}'"
        }
        return jsonify(error_response), 404

    # Eliminar la fila de la tabla environments
    cursor.execute("DELETE FROM environments WHERE env=?", (env,))
    conn.commit()
    conn.close()

    # Ejecutar el proceso Bash en segundo plano
    subprocess.Popen([DESTROY_COMMAND, env])

    # Respuesta JSON indicando que la operación fue exitosa
    response = {
        'message': f"Iniciado la eliminacion del entorno '{env}''."
    }
    return jsonify(response)

@app.route('/state')
def get_process_state():
    env = request.args.get('env')  # Obtener el parámetro 'file' de la URL
    log_file = f'{FILE_PATH_PREFIX}/{env}/creation.log' 

    # Verificar si el archivo existe
    if not os.path.exists(log_file):
        error_response = {
            'error': f"El entorno '{env}' no existe."
        }
        return jsonify(error_response), 404

    # Abrir el archivo de registro
    with open(log_file, 'r') as file:
        # Leer las líneas del archivo
        lines = file.readlines()

    # Patrones, porcentajes y mensajes correspondientes
    patterns = [
        (15,  'Creando VPC',        'aws_vpc.vpc: Creating'),
        (40,  'Creando subredes',   'aws_security_group.instance-sg: Creating'),
        (70,  'Creando instancias', 'aws_instance.instance[0]: Creating...'),
        (100, 'Finalizado',         'Apply complete! Resources'),
    ]  

    response = {
        'percentage': 0,
        'message': 'Preparando infraestructura'
    }

    for line in lines:
        for percentage, message, pattern in patterns:
            if pattern in line:
                response = {
                    'percentage': percentage,
                    'message': message
                }

    return jsonify(response)

@app.route('/list')
def list_environments():
    # Obtener los registros de la tabla environments
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM environments")
    rows = cursor.fetchall()
    conn.close()

    # Crear una lista de diccionarios con los datos de los registros
    environments = []
    for row in rows:
        environment = {
            'env': row[0],
            'correo': row[1],
            'nombre': row[2],
            'nodos': row[3]
        }
        environments.append(environment)

    # Devolver los registros como respuesta JSON
    return jsonify(environments)

if __name__ == '__main__':
    # Comprobar si la base de datos y la tabla existen, y crear la tabla si es necesario
    if not os.path.exists(DATABASE):
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        cursor.execute(f"""
            CREATE TABLE IF NOT EXISTS environments (
                env TEXT PRIMARY KEY,
                correo TEXT,
                nombre TEXT,
                tipo TEXT,
                nodos INTEGER
            )
        """)
        conn.commit()
        conn.close()

    app.run()
