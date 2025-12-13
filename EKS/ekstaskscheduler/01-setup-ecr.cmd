@echo off
REM Setup ECR repositories and get AWS account information

echo ======================================
echo AWS Account and ECR Repository Setup
echo ======================================
echo.

echo Getting AWS Account ID...
for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Account --output text') do set AWS_ACCOUNT_ID=%%i

if "%AWS_ACCOUNT_ID%"=="" (
    echo ERROR: Could not get AWS Account ID. Make sure AWS CLI is configured.
    pause
    exit /b 1
)

echo AWS Account ID: %AWS_ACCOUNT_ID%
echo.

echo Enter your AWS region (e.g., us-east-1):
set /p AWS_REGION=

echo.
echo ======================================
echo Creating ECR Repositories...
echo ======================================
echo.

echo Creating ekswebapi repository...
aws ecr create-repository --repository-name ekswebapi --region %AWS_REGION% 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ ekswebapi repository created
) else (
    echo ℹ ekswebapi repository already exists or error occurred
)

echo.
echo Creating ekstaskscheduler repository...
aws ecr create-repository --repository-name ekstaskscheduler --region %AWS_REGION% 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ ekstaskscheduler repository created
) else (
    echo ℹ ekstaskscheduler repository already exists or error occurred
)

echo.
echo ======================================
echo Repository Information
echo ======================================
echo.
echo Your ECR Repository URL: %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
echo.
echo Web API Image: %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/ekswebapi:latest
echo Scheduler Image: %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/ekstaskscheduler:latest
echo.

echo Saving configuration to config.txt...
(
    echo AWS_ACCOUNT_ID=%AWS_ACCOUNT_ID%
    echo AWS_REGION=%AWS_REGION%
    echo ECR_REPO=%AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
) > config.txt

echo.
echo ✓ Configuration saved to config.txt
echo.
echo Next steps:
echo 1. Run 02-login-ecr.cmd to authenticate with ECR
echo 2. Run 03-build-push-images.cmd to build and push Docker images
echo.
pause
