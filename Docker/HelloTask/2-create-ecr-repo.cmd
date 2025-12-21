@echo off
REM Step 2: Create Amazon ECR repository
REM This creates a container registry to store the Docker image
REM
REM Usage: 2-create-ecr-repo.cmd <aws-region> [repository-name]
REM Example: 2-create-ecr-repo.cmd us-east-1 hello-task

if "%1"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: 2-create-ecr-repo.cmd ^<aws-region^> [repository-name]
    echo Example: 2-create-ecr-repo.cmd us-east-1 hello-task
    exit /b 1
)

set AWS_REGION=%1
set REPOSITORY_NAME=%2
if "%REPOSITORY_NAME%"=="" set REPOSITORY_NAME=hello-task

echo ================================================
echo STEP 2: Create ECR Repository
echo ================================================
echo Region: %AWS_REGION%
echo Repository: %REPOSITORY_NAME%
echo ================================================
echo.

aws ecr create-repository ^
    --repository-name %REPOSITORY_NAME% ^
    --region %AWS_REGION% ^
    --image-scanning-configuration scanOnPush=true

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS: ECR repository created!
    echo ================================================
    echo.
    echo Next Step: Run 3-push-to-ecr.cmd %AWS_REGION%
) else (
    echo.
    echo ================================================
    echo NOTE: Repository may already exist
    echo ================================================
    echo.
    echo Next Step: Run 3-push-to-ecr.cmd %AWS_REGION%
)
