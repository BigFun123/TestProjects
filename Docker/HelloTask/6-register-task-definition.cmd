@echo off
REM Step 6: Register ECS Task Definition
REM This defines how the container should run
REM
REM Usage: 6-register-task-definition.cmd <aws-account-id> <aws-region> [repository-name]
REM Example: 6-register-task-definition.cmd 123456789012 us-east-1 hello-task

if "%1"=="" (
    echo ERROR: AWS Account ID is required
    echo.
    echo Usage: 6-register-task-definition.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: 6-register-task-definition.cmd 123456789012 us-east-1 hello-task
    exit /b 1
)

if "%2"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: 6-register-task-definition.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: 6-register-task-definition.cmd 123456789012 us-east-1 hello-task
    exit /b 1
)

set AWS_ACCOUNT_ID=%1
set AWS_REGION=%2
set REPOSITORY_NAME=%3
if "%REPOSITORY_NAME%"=="" set REPOSITORY_NAME=hello-task
set IMAGE_URI=%AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/%REPOSITORY_NAME%:latest
set EXECUTION_ROLE_ARN=arn:aws:iam::%AWS_ACCOUNT_ID%:role/ecsTaskExecutionRole

echo ================================================
echo STEP 6: Register ECS Task Definition
echo ================================================
echo Account ID: %AWS_ACCOUNT_ID%
echo Region: %AWS_REGION%
echo Image URI: %IMAGE_URI%
echo ================================================
echo.

echo Updating task definition with your image URI...
powershell -Command "(Get-Content task-definition.json) -replace '<AWS_ACCOUNT_ID>', '%AWS_ACCOUNT_ID%' -replace '<AWS_REGION>', '%AWS_REGION%' -replace '<REPOSITORY_NAME>', '%REPOSITORY_NAME%' | Set-Content task-definition-temp.json"
echo.

echo Registering task definition...
aws ecs register-task-definition ^
    --cli-input-json file://task-definition-temp.json ^
    --region %AWS_REGION%

if %errorlevel% equ 0 (
    echo.
    del task-definition-temp.json
    echo ================================================
    echo SUCCESS: Task definition registered!
    echo ================================================
    echo.
    echo Next Step: Run 7-create-eventbridge-rule.cmd %AWS_REGION%
) else (
    echo.
    del task-definition-temp.json
    echo ================================================
    echo ERROR: Failed to register task definition
    echo ================================================
    exit /b 1
)
