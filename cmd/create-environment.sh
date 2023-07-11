#!/bin/bash
set -e

CONFIG=/opt/clustercreator/config
BASE_TERRAFORM=/opt/clustercreator/terraform

ENV_NAME=$1
N_NODOS=$2

mkdir $CONFIG/$ENV_NAME

terraform -chdir=$BASE_TERRAFORM \
  apply \
  -auto-approve \
  -no-color \
  -var="cliente=$ENV_NAME" \
  -var="nodes_count=$N_NODOS" \
  -state=$CONFIG/$ENV_NAME/tf-state.json 2>&1 | ts -s >> $CONFIG/$ENV_NAME/creation.log 

# ¿Como comprobar o esperar a que el slurm ya esté listo?
# Envio de correo informando de la creación del entorno