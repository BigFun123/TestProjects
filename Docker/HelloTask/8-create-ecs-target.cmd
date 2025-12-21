@echo off
REM Step 8: Add ECS Task as Target to EventBridge Rule
REM This connects the schedule to the ECS task
REM
REM Usage: 8-create-ecs-target.cmd <aws-account-id> <aws-region> [subnet-id-1] [subnet-id-2] [security-group-id]
REM Example: 8-create-ecs-target.cmd 123456789012 us-east-1 subnet-abc123 subnet-def456 sg-xyz789

if "%1"=="" (
    echo ERROR: AWS Account ID is required
    echo.
    echo Usage: 8-create-ecs-target.cmd ^<aws-account-id^> ^<aws-region^> [subnet-id-1] [subnet-id-2] [security-group-id]
    echo Example: 8-create-ecs-target.cmd 123456789012 us-east-1 subnet-abc123 subnet-def456 sg-xyz789
    echo.
    echo Note: If subnet and security group IDs are not provided, you'll need to edit ecs-target.json manually
    exit /b 1
)

if "%2"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: 8-create-ecs-target.cmd ^<aws-account-id^> ^<aws-region^> [subnet-id-1] [subnet-id-2] [security-group-id]
    echo Example: 8-create-ecs-target.cmd 123456789012 us-east-1 subnet-abc123 subnet-def456 sg-xyz789
    exit /b 1
)

set AWS_ACCOUNT_ID=%1
set AWS_REGION=%2
set SUBNET_1=%3
set SUBNET_2=%4
set SECURITY_GROUP=%5
set RULE_NAME=hello-task-hourly
set CLUSTER_NAME=hello-task-cluster
set TASK_DEFINITION=hello-task

echo ================================================
echo STEP 8: Add ECS Target to EventBridge Rule
echo ================================================
echo Account ID: %AWS_ACCOUNT_ID%
echo Region: %AWS_REGION%
echo Rule: %RULE_NAME%
echo Cluster: %CLUSTER_NAME%
echo Task Definition: %TASK_DEFINITION%
echo ================================================
echo.

if "%SUBNET_1%"=="" (
    echo WARNING: No subnet IDs provided
    echo You will need to manually edit ecs-target.json with your VPC subnet IDs
    echo.
    echo To find your default VPC subnets, run:
    echo   aws ec2 describe-subnets --region %AWS_REGION% --filters "Name=default-for-az,Values=true"
    echo.
    pause
    exit /b 1
)

if "%SECURITY_GROUP%"=="" (
    echo WARNING: No security group ID provided
    echo You will need to manually edit ecs-target.json with your security group ID
    echo.
    echo To find your default security group, run:
    echo   aws ec2 describe-security-groups --region %AWS_REGION% --filters "Name=group-name,Values=default"
    echo.
    pause
    exit /b 1
)

echo Preparing ECS target configuration...
powershell -Command "$content = Get-Content ecs-target.json -Raw; $content = $content -replace '<AWS_ACCOUNT_ID>', '%AWS_ACCOUNT_ID%' -replace '<AWS_REGION>', '%AWS_REGION%' -replace '<CLUSTER_NAME>', '%CLUSTER_NAME%' -replace '<TASK_DEFINITION>', '%TASK_DEFINITION%' -replace '<SUBNET_1>', '%SUBNET_1%' -replace '<SUBNET_2>', '%SUBNET_2%' -replace '<SECURITY_GROUP>', '%SECURITY_GROUP%'; $content | Set-Content ecs-target-temp.json"
echo.

echo Adding ECS target to EventBridge rule...
aws events put-targets ^
    --rule %RULE_NAME% ^
    --targets file://ecs-target-temp.json ^
    --region %AWS_REGION%

if %errorlevel% equ 0 (
    echo.
    del ecs-target-temp.json
    echo ================================================
    echo SUCCESS: ECS target added to EventBridge rule!
    echo ================================================
    echo.
    echo Your scheduled task is now active!
    echo It will run every hour at minute 0.
    echo.
    echo To verify: Run 9-verify-setup.cmd %AWS_REGION%
) else (
    echo.
    del ecs-target-temp.json
    echo ================================================
    echo ERROR: Failed to add ECS target
    echo ================================================
    exit /b 1
)
