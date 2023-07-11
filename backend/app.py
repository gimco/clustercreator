from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
from db import DatabaseManager
from cmd import terraform_create, terraform_destroy, terraform_estimated_progress, terraform_get_url

app = Flask(__name__, static_folder='static')
CORS(app)
db = DatabaseManager()


@app.route('/')
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def home(path):
    if path != '':
        return send_from_directory(app.static_folder, path)
    else:
        return send_from_directory(app.static_folder, 'index.html')


@app.route('/list')
def list_environments():
    environments = db.all_environments()
    return jsonify(environments)


@app.route('/destroy')
def destroy_environment():
    env = request.args.get('env')

    # Eliminamos de base de datos e iniciamos eliminación
    db.delete_environment(env)
    terraform_destroy(env)

    return jsonify({'message': f"Iniciado la eliminacion del entorno '{env}'."})


@app.route('/create')
def create_environment():
    env = request.args.get('env')
    correo = request.args.get('correo')
    nombre = request.args.get('nombre')
    tipo = request.args.get('tipo')

    # Validar nodos
    print(request.args.get('nodos'))
    nodos = int(request.args.get('nodos'))
    if (nodos < 1 or nodos > 10): return error('nodos incorrectos')

    # Comprobar que no exista
    row = db.get_environment(env)
    if row is not None: return error(f"El entorno '{env}' ya existe.")

    # Ejecutar el proceso Bash en segundo plano
    pid = terraform_create(env, str(nodos))
    db.create_environment(env, correo, nombre, tipo, nodos, pid)

    return jsonify({'message': 'Creación del entorno iniciado.'})


@app.route('/status')
def get_process_state():
    env = request.args.get('env')

    # Comprobamos que exista
    row = db.get_environment(env)
    if row is None: return error(f"El entorno '{env}' no existe.")

    # Obtenemos el progreso
    progress = terraform_estimated_progress(env, row['pid'])
    if progress is None: return error(f"El proceso de creación se detuvo de forma inesperada.")

    # Se ha finalizado obtener la url
    if progress['percentage_start'] == 100:
        url = terraform_get_url(env)
        db.update_url_environment(env, url)
        progress['url'] = url

    return jsonify(progress)


def error(message):
    return jsonify({'error': message}), 400


if __name__ == '__main__':
    app.run()



