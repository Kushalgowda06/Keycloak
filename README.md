# Keycloak Deployment

This repository packages a custom Keycloak image and a helper script for publishing it to Amazon Elastic Container Registry (ECR).

## Prerequisites
- Docker installed and running.
- AWS CLI v2 configured with credentials that have permission to create repositories and push images in the target account.
- An active session with access to the `ap-south-1` region.

## Building and Pushing to ECR

Run the helper script to build the Docker image defined in the local `Dockerfile` and push it to ECR:

```
./deploy.sh
```

By default the script:
- Builds the image using the repository root `Dockerfile`.
- Tags the image with the current Git commit SHA (or timestamp when Git is unavailable) and `latest`.
- Pushes to `361568250748.dkr.ecr.ap-south-1.amazonaws.com/keycloak`.
- Creates the ECR repository automatically if it does not exist.

### Customising the Deployment

You can override configuration at runtime via environment variables:

```
AWS_REGION=ap-south-1 \
AWS_ACCOUNT_ID=361568250748 \
ECR_REPOSITORY=keycloak \
IMAGE_TAG=my-feature \
./deploy.sh
```

The resulting image will be available under both `:${IMAGE_TAG}` and `:latest` tags in the specified repository.
