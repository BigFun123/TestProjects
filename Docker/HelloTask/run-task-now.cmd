@echo off
REM Helper: Run Task Manually (for testing)
REM This runs the ECS task immediately without waiting for the schedule
REM
REM Usage: run-task-now.cmd <aws-region> <subnet-id-1> <subnet-id-2> <security-group-id>
REM Example: run-task-now.cmd us-east-1 subnet-abc123 subnet-def456 sg-xyz789

if "%1"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: run-task-now.cmd ^<aws-region^> ^<subnet-id-1^> ^<subnet-id-2^> ^<security-group-id^>
    echo Example: run-task-now.cmd us-east-1 subnet-abc123 subnet-def456 sg-xyz789
    exit /b 1
)

if "%2"=="" (
    echo ERROR: Subnet ID 1 is required
    echo Run get-subnet-ids.cmd %1 to find your subnet IDs
    exit /b 1
)

if "%3"=="" (
    echo ERROR: Subnet ID 2 is required
    echo Run get-subnet-ids.cmd %1 to find your subnet IDs
    exit /b 1
)

if "%4"=="" (
    echo ERROR: Security Group ID is required
    echo Run get-subnet-ids.cmd %1 to find your security group ID
    exit /b 1
)

set AWS_REGION=%1
set SUBNET_1=%2
set SUBNET_2=%3
set SECURITY_GROUP=%4
set CLUSTER_NAME=hello-task-cluster
set TASK_DEFINITION=hello-task

echo ================================================
echo Running ECS Task Manually
echo ================================================
echo Region: %AWS_REGION%
echo Cluster: %CLUSTER_NAME%
echo Task Definition: %TASK_DEFINITION%
echo ================================================
echo.

aws ecs run-task ^
    --cluster %CLUSTER_NAME% ^
    --task-definition %TASK_DEFINITION% ^
    --launch-type FARGATE ^
    --network-configuration "awsvpcConfiguration={subnets=[%SUBNET_1%,%SUBNET_2%],securityGroups=[%SECURITY_GROUP%],assignPublicIp=ENABLED}" ^
    --region %AWS_REGION%

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS: Task started!
    echo ================================================
    echo.
    echo Check CloudWatch Logs in a few moments:
    echo   view-logs.cmd %AWS_REGION%
) else (
    echo.
    echo ================================================
    echo ERROR: Failed to start task
    echo ================================================
    exit /b 1
)
