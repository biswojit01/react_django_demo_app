#!/bin/bash

set -e  # Stop on error

echo "Reading image details..."
IMAGE=$(cat /opt/scripts/imageDetail.txt | cut -d '=' -f2)

echo "Logging into Docker Hub..."
AWS_REGION="us-east-1"  # Change this to your AWS region

export DOCKERHUB_USERNAME=$(aws secretsmanager get-secret-value --region $AWS_REGION --secret-id dockerhub-credentials --query 'SecretString' --output text | jq -r .DOCKERHUB_USERNAME)
export DOCKERHUB_PASSWORD=$(aws secretsmanager get-secret-value --region $AWS_REGION --secret-id dockerhub-credentials --query 'SecretString' --output text | jq -r .DOCKERHUB_PASSWORD)

if [[ -z "$DOCKERHUB_USERNAME" || -z "$DOCKERHUB_PASSWORD" ]]; then
  echo "Error: DockerHub credentials not found in AWS Secrets Manager."
  exit 1
fi

echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

echo "Pulling Docker image: $IMAGE"
docker pull $IMAGE

echo "Updating Docker Swarm service..."
#docker service update --image $IMAGE django_app || docker service create --name django_app --publish 8000:8000 $IMAGE

docker service update --image $IMAGE django_app || \
docker service create --name django_app --mode global --publish 8000:8000 --constraint 'node.role==worker' $IMAGE
