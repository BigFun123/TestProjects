@echo off
REM Build, push, and deploy HelloEKS to Amazon EKS
REM This script automates the entire workflow
REM
REM Usage: build-push-deploy.cmd <aws-account-id> <aws-region> [repository-name]
REM Example: build-push-deploy.cmd 123456789012 us-east-1 hello-eks

if "%1"=="" (
    echo Error: AWS Account ID is required
    echo Usage: build-push-deploy.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: build-push-deploy.cmd 123456789012 us-east-1 hello-eks
    exit /b 1
)

if "%2"=="" (
    echo Error: AWS Region is required
    echo Usage: build-push-deploy.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: build-push-deploy.cmd 123456789012 us-east-1 hello-eks
    exit /b 1
)

set AWS_ACCOUNT_ID=%1
set AWS_REGION=%2
set REPOSITORY_NAME=%3

echo ================================================
echo HelloEKS - Full Deployment Pipeline
echo ================================================
echo.

echo Step 1: Building Docker image...
call build.cmd
if %errorlevel% neq 0 exit /b 1
echo.

echo Step 2: Pushing to Amazon ECR...
if "%REPOSITORY_NAME%"=="" (
    call push-to-ecr.cmd %AWS_ACCOUNT_ID% %AWS_REGION%
) else (
    call push-to-ecr.cmd %AWS_ACCOUNT_ID% %AWS_REGION% %REPOSITORY_NAME%
)
if %errorlevel% neq 0 exit /b 1
echo.

echo Step 3: Deploying to Amazon EKS...
if "%REPOSITORY_NAME%"=="" (
    call deploy-to-eks.cmd %AWS_ACCOUNT_ID% %AWS_REGION%
) else (
    call deploy-to-eks.cmd %AWS_ACCOUNT_ID% %AWS_REGION% %REPOSITORY_NAME%
)
if %errorlevel% neq 0 exit /b 1
echo.

echo ================================================
echo Full deployment completed successfully!
echo ================================================
echo.
echo Run 'logs.cmd' to view application logs
echo Run 'status.cmd' to check deployment status
