import os
import subprocess
import psutil
import json
from eta import estimated_progress

FILE_PATH_PREFIX = '/opt/clustercreator/config'
CREATE_COMMAND= '/opt/clustercreator/cmd/create-environment.sh'
DESTROY_COMMAND= '/opt/clustercreator/cmd/destroy-environment.sh'

def handle_sigchld(signum, frame):
    pass

def execute_command(command):
    process = subprocess.Popen(command)
    return process.pid

def terraform_create(env, nodos):
    return execute_command([CREATE_COMMAND, env, nodos])

def terraform_destroy(env):
    execute_command([DESTROY_COMMAND, env])


def terraform_running(pid):
    running = psutil.pid_exists(pid)
    if not running: return False

    # Comprobar que no esa proceso zombie
    proc = psutil.Process(pid)
    return proc.status() != psutil.STATUS_ZOMBIE

def terraform_get_url(env):
    # Analizar un archivo JSON
    with open(f'{FILE_PATH_PREFIX}/{env}/tf-state.json') as tf_state_json:
        data = json.load(tf_state_json)
        value = data["outputs"]["master_public_ip"]["value"][0][0]
        return f"http://{value}:8888"

def terraform_estimated_progress(env, pid):
    # Verificar si el archivo log existe
    log_file = f'{FILE_PATH_PREFIX}/{env}/creation.log' 
    if not os.path.exists(log_file): return None

    # Leer las líneas del archivo de log
    with open(log_file, 'r') as file:
        lines = file.readlines()

    # Patrones, porcentajes y mensajes correspondientes
    progress = estimated_progress(lines)

    if progress["percentage_start"] != 100 and not terraform_running(pid):
        return None

    return progress

