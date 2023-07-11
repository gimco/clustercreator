#!/bin/bash
set -e

ENV_NAME=$1
CONFIG=/opt/clustercreator/config
BASE_TERRAFORM=/opt/clustercreator/terraform

terraform -chdir=$BASE_TERRAFORM \
  destroy \
  -auto-approve \
  -no-color \
  -state=$CONFIG/$ENV_NAME/tf-state.json \
  -state-out=$CONFIG/$ENV_NAME/tf-state-final.json > $CONFIG/$ENV_NAME/destroy.log 2>&1

mv $CONFIG/$ENV_NAME $CONFIG/${ENV_NAME}_destroy_$(date '+%Y%m%d%H%M%S')

# ¿Enviar correo de destrucción del entorno? 