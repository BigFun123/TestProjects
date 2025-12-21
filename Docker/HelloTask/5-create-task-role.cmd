@echo off
REM Step 5: Create IAM Role for ECS Task Execution
REM This creates the role that allows ECS to pull images and write logs
REM
REM Usage: 5-create-task-role.cmd <aws-region>
REM Example: 5-create-task-role.cmd us-east-1

if "%1"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: 5-create-task-role.cmd ^<aws-region^>
    echo Example: 5-create-task-role.cmd us-east-1
    exit /b 1
)

set AWS_REGION=%1
set ROLE_NAME=ecsTaskExecutionRole

echo ================================================
echo STEP 5: Create IAM Role for ECS Task Execution
echo ================================================
echo Region: %AWS_REGION%
echo Role: %ROLE_NAME%
echo ================================================
echo.

echo Creating IAM role...
aws iam create-role ^
    --role-name %ROLE_NAME% ^
    --assume-role-policy-document file://task-execution-assume-role-policy.json ^
    --description "ECS Task Execution Role for HelloTask"

if %errorlevel% equ 0 (
    echo Role created successfully.
) else (
    echo NOTE: Role may already exist.
)
echo.

echo Attaching execution policy...
aws iam attach-role-policy ^
    --role-name %ROLE_NAME% ^
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

if %errorlevel% equ 0 (
    echo Policy attached successfully.
) else (
    echo NOTE: Policy may already be attached.
)
echo.

echo Waiting 10 seconds for IAM role to propagate...
timeout /t 10 /nobreak >nul
echo.

echo ================================================
echo SUCCESS: IAM role configured!
echo Role: %ROLE_NAME%
echo ================================================
echo.
echo Next Step: Run 6-register-task-definition.cmd (AWS_ACCOUNT_ID) %AWS_REGION%
