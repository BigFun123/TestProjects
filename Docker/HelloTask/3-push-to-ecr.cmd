@echo off
REM Step 3: Push Docker image to Amazon ECR
REM This uploads the container image to the AWS registry
REM
REM Usage: 3-push-to-ecr.cmd <aws-account-id> <aws-region> [repository-name]
REM Example: 3-push-to-ecr.cmd 123456789012 us-east-1 hello-task

if "%1"=="" (
    echo ERROR: AWS Account ID is required
    echo.
    echo Usage: 3-push-to-ecr.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: 3-push-to-ecr.cmd 123456789012 us-east-1 hello-task
    exit /b 1
)

if "%2"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: 3-push-to-ecr.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: 3-push-to-ecr.cmd 123456789012 us-east-1 hello-task
    exit /b 1
)

set AWS_ACCOUNT_ID=%1
set AWS_REGION=%2
set REPOSITORY_NAME=%3
if "%REPOSITORY_NAME%"=="" set REPOSITORY_NAME=hello-task
set ECR_REGISTRY=%AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
set IMAGE_URI=%ECR_REGISTRY%/%REPOSITORY_NAME%:latest

echo ================================================
echo STEP 3: Push to Amazon ECR
echo ================================================
echo Account ID: %AWS_ACCOUNT_ID%
echo Region: %AWS_REGION%
echo Repository: %REPOSITORY_NAME%
echo Image URI: %IMAGE_URI%
echo ================================================
echo.

echo Authenticating with ECR...
aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_REGISTRY%
if %errorlevel% neq 0 (
    echo ERROR: Failed to authenticate with ECR
    exit /b 1
)
echo.

echo Tagging Docker image...
docker tag hello-task:latest %IMAGE_URI%
if %errorlevel% neq 0 (
    echo ERROR: Failed to tag image
    exit /b 1
)
echo.

echo Pushing image to ECR...
docker push %IMAGE_URI%
if %errorlevel% neq 0 (
    echo ERROR: Failed to push image
    exit /b 1
)
echo.

echo ================================================
echo SUCCESS: Image pushed to ECR!
echo Image URI: %IMAGE_URI%
echo ================================================
echo.
echo Save this for the next steps:
echo IMAGE_URI=%IMAGE_URI%
echo.
echo Next Step: Run 4-create-ecs-cluster.cmd %AWS_REGION%
