#!/usr/bin/env bash

set -euo pipefail

AWS_REGION=${AWS_REGION:-ap-south-1}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-361568250748}
ECR_REPOSITORY=${ECR_REPOSITORY:-keycloak}
IMAGE_TAG=${IMAGE_TAG:-}

REPOSITORY_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"

if [[ -z "${IMAGE_TAG}" ]]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    IMAGE_TAG=$(git rev-parse --short HEAD)
  else
    IMAGE_TAG=$(date +%Y%m%d%H%M%S)
  fi
fi

FULL_IMAGE_TAG="${REPOSITORY_URI}:${IMAGE_TAG}"
LATEST_IMAGE_TAG="${REPOSITORY_URI}:latest"

command -v aws >/dev/null 2>&1 || {
  echo "aws CLI is required but not found in PATH" >&2
  exit 1
}

command -v docker >/dev/null 2>&1 || {
  echo "Docker is required but not found in PATH" >&2
  exit 1
}

echo "Ensuring ECR repository ${ECR_REPOSITORY} exists in ${AWS_REGION}..."
aws ecr describe-repositories \
  --repository-names "${ECR_REPOSITORY}" \
  --region "${AWS_REGION}" >/dev/null 2>&1 || {
    aws ecr create-repository \
      --repository-name "${ECR_REPOSITORY}" \
      --region "${AWS_REGION}" \
      >/dev/null
  }

echo "Authenticating Docker to Amazon ECR..."
aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Building Docker image ${FULL_IMAGE_TAG}..."
docker build -t "${FULL_IMAGE_TAG}" -f Dockerfile .

echo "Tagging image as ${LATEST_IMAGE_TAG}..."
docker tag "${FULL_IMAGE_TAG}" "${LATEST_IMAGE_TAG}"

echo "Pushing image ${FULL_IMAGE_TAG}..."
docker push "${FULL_IMAGE_TAG}"

echo "Pushing image ${LATEST_IMAGE_TAG}..."
docker push "${LATEST_IMAGE_TAG}"

echo "Deployment artifacts pushed successfully."
echo "Image tags available:"
echo "  ${FULL_IMAGE_TAG}"
echo "  ${LATEST_IMAGE_TAG}"
