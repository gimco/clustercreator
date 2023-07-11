#!/bin/bash

CONFIG=/opt/clustercreator/config
BASE_TERRAFORM=/opt/clustercreator/terraform

ENV_NAME=$1
N_NODOS=$2

# Faltaría recibir ademas los parametros de tipo y nodos
# Para pasarlos a comando de terraform -var="nnodos=$2"

mkdir $CONFIG/$ENV_NAME
terraform -chdir=$BASE_TERRAFORM \
  apply \
  -auto-approve \
  -no-color \
  -state=$CONFIG/$ENV_NAME/tf-state.json 2>&1 | ts -s >> $CONFIG/$ENV_NAME/creation.log 

# ¿Como comprobar o esperar a que el slurm ya esté listo?
# Envio de correo informando de la creación del entorno