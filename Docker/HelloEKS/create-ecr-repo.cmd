@echo off
REM Create ECR repository for HelloEKS
REM
REM Usage: create-ecr-repo.cmd <aws-region> [repository-name]
REM Example: create-ecr-repo.cmd us-east-1 hello-eks

if "%1"=="" (
    echo Error: AWS Region is required
    echo Usage: create-ecr-repo.cmd ^<aws-region^> [repository-name]
    echo Example: create-ecr-repo.cmd us-east-1 hello-eks
    exit /b 1
)

set AWS_REGION=%1
set REPOSITORY_NAME=%2
if "%REPOSITORY_NAME%"=="" set REPOSITORY_NAME=hello-eks

echo Creating ECR repository: %REPOSITORY_NAME% in %AWS_REGION%...
echo.

aws ecr create-repository ^
    --repository-name %REPOSITORY_NAME% ^
    --region %AWS_REGION% ^
    --image-scanning-configuration scanOnPush=true

if %errorlevel% equ 0 (
    echo.
    echo ECR repository created successfully!
    echo Repository: %REPOSITORY_NAME%
    echo Region: %AWS_REGION%
) else (
    echo.
    echo Note: Repository may already exist or there was an error.
)
