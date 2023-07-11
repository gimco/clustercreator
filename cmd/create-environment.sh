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

# Obtener la IP publica del nodo master
JUPYTER=$(cat $CONFIG/$ENV_NAME/tf-state.json | jq -r .outputs.master_public_ip.value[0][0])
if [ $JUPYTER = "null" ]; then
  exit 1
fi

# Esperar a que jupyter esté listo
while ! nc -z $JUPYTER 8888 &> /dev/null
do
  printf "%c" "."
done

echo "Jupyter disponible!" >> $CONFIG/$ENV_NAME/creation.log
