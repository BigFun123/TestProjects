#!/bin/bash

set -e

REGION=us-east-1
ACCOUNT_ID=984778981719
REPO_NAME=hello-app
IMAGE_URI=${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:latest

# Build Docker image
docker build -t ${REPO_NAME} ../tester

# Create ECR repo if not exists
aws ecr describe-repositories --repository-names ${REPO_NAME} --region ${REGION} || aws ecr create-repository --repository-name ${REPO_NAME} --region ${REGION}

# Login to ECR
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Tag and push
docker tag ${REPO_NAME}:latest ${IMAGE_URI}
docker push ${IMAGE_URI}

# Create ECS cluster
aws ecs create-cluster --cluster-name hello-cluster --region ${REGION}

# Register task definition
cat > task-definition.json << EOF
{
    "family": "hello-task",
    "taskRoleArn": "",
    "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/ecsTaskExecutionRole",
    "networkMode": "awsvpc",
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "256",
    "memory": "512",
    "containerDefinitions": [
        {
            "name": "hello-container",
            "image": "${IMAGE_URI}",
            "essential": true
        }
    ]
}
EOF

aws ecs register-task-definition --cli-input-json file://task-definition.json --region ${REGION}
rm task-definition.json