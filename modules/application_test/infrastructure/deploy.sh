#!/bin/bash

if [ ! -f ".env" ]; then
  echo "'.env' file is not exists"
  exit
fi

LIST=("AWS_ACCOUNT_ID" "REGION" "SERVICE_TAG" "SERVICE_NAME")

containsElement() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 1; done
  return 0
}

while read -r line || [[ -n "$line" ]]; do
  IFS='=' read -r key value <<<"$line"
  containsElement "$key" "${LIST[@]}"
  if [ $? ]; then
    eval "$key=$value"
  fi
done <.env

ECR_REPO_URL=$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$SERVICE_NAME

echo "$ECR_REPO_URL"

if [ "$1" = "build" ]; then
  echo "Building the application..."
  cd ..
  sh mvnw clean install
elif [ "$1" = "dockerize" ]; then
  find ../target/ -type f \( -name "*.jar" -not -name "*sources.jar" \) -exec cp {} ../infrastructure/"$SERVICE_NAME".jar \;
  eval "$(aws ecr get-login --no-include-email --region "$REGION")"
  aws ecr create-repository --repository-name "${SERVICE_NAME:?}" || true
  docker build -t "${SERVICE_NAME}:${SERVICE_TAG}" .
  docker tag "${SERVICE_NAME}:${SERVICE_TAG} ${ECR_REPO_URL}:${SERVICE_TAG}"
  docker push "${ECR_REPO_URL}:${SERVICE_TAG}"
elif [ "$1" = "plan" ]; then
  terraform init -backend-config="app-prod.config"
  terraform plan -var-file="production.tfvars" -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}"
elif [ "$1" = "deploy" ]; then
  terraform init -backend-config="app-prod.config"
  terraform taint -allow-missing aws_ecs_task_definition.springbootapp-task-definition
  terraform apply -var-file="production.tfvars" -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}" -auto-approve
elif [ "$1" = "destroy" ]; then
  terraform init -backend-config="app-prod.config"
  terraform destroy -var-file="production.tfvars" -var "docker_image_url=${ECR_REPO_URL}:${SERVICE_TAG}" -auto-approve
fi
