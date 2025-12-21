@echo off
REM Push Docker image to Amazon ECR
REM Prerequisites:
REM   - AWS CLI installed and configured
REM   - Docker running
REM   - ECR repository created
REM
REM Usage: push-to-ecr.cmd <aws-account-id> <aws-region> [repository-name]
REM Example: push-to-ecr.cmd 123456789012 us-east-1 hello-eks

if "%1"=="" (
    echo Error: AWS Account ID is required
    echo Usage: push-to-ecr.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: push-to-ecr.cmd 123456789012 us-east-1 hello-eks
    exit /b 1
)

if "%2"=="" (
    echo Error: AWS Region is required
    echo Usage: push-to-ecr.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: push-to-ecr.cmd 123456789012 us-east-1 hello-eks
    exit /b 1
)

set AWS_ACCOUNT_ID=%1
set AWS_REGION=%2
set REPOSITORY_NAME=%3
if "%REPOSITORY_NAME%"=="" set REPOSITORY_NAME=hello-eks
set ECR_REGISTRY=%AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
set IMAGE_URI=%ECR_REGISTRY%/%REPOSITORY_NAME%:latest

echo ================================================
echo Pushing to Amazon ECR
echo ================================================
echo AWS Account: %AWS_ACCOUNT_ID%
echo AWS Region: %AWS_REGION%
echo Repository: %REPOSITORY_NAME%
echo Image URI: %IMAGE_URI%
echo ================================================
echo.

echo Step 1: Authenticate Docker with ECR...
aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_REGISTRY%
if %errorlevel% neq 0 (
    echo Failed to authenticate with ECR
    exit /b 1
)
echo.

echo Step 2: Tag the Docker image...
docker tag hello-eks:latest %IMAGE_URI%
if %errorlevel% neq 0 (
    echo Failed to tag image
    exit /b 1
)
echo.

echo Step 3: Push the image to ECR...
docker push %IMAGE_URI%
if %errorlevel% neq 0 (
    echo Failed to push image to ECR
    exit /b 1
)
echo.

echo ================================================
echo Successfully pushed image to ECR!
echo Image URI: %IMAGE_URI%
echo ================================================
echo.
echo Next steps:
echo 1. Update deployment.yaml with the image URI
echo 2. Run deploy-to-eks.cmd to deploy to your EKS cluster
