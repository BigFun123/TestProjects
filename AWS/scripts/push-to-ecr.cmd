@echo off
REM Push Docker image to Amazon ECR
echo ===================================
echo Push Docker Image to Amazon ECR
echo ===================================

REM Set your variables here
set AWS_REGION=us-east-1
set AWS_ACCOUNT_ID=YOUR_AWS_ACCOUNT_ID
set ECR_REPOSITORY=helloworld-app
set IMAGE_TAG=latest

echo.
echo Step 1: Authenticate Docker to ECR...
aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com

if %ERRORLEVEL% NEQ 0 (
    echo ECR login failed! Make sure AWS CLI is configured.
    exit /b 1
)

echo.
echo Step 2: Tag the Docker image...
docker tag helloworld-app:latest %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/%ECR_REPOSITORY%:%IMAGE_TAG%

echo.
echo Step 3: Push the image to ECR...
docker push %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/%ECR_REPOSITORY%:%IMAGE_TAG%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===================================
    echo Image pushed successfully!
    echo ===================================
    echo Image URI: %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/%ECR_REPOSITORY%:%IMAGE_TAG%
    echo.
    echo Update k8s/deployment.yaml with this image URI.
) else (
    echo Push failed!
    exit /b 1
)
