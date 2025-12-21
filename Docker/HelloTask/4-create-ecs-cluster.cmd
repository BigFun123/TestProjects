@echo off
REM Step 4: Create Amazon ECS Cluster
REM This creates a cluster to run the scheduled tasks
REM
REM Usage: 4-create-ecs-cluster.cmd <aws-region> [cluster-name]
REM Example: 4-create-ecs-cluster.cmd us-east-1 hello-task-cluster

if "%1"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: 4-create-ecs-cluster.cmd ^<aws-region^> [cluster-name]
    echo Example: 4-create-ecs-cluster.cmd us-east-1 hello-task-cluster
    exit /b 1
)

set AWS_REGION=%1
set CLUSTER_NAME=%2
if "%CLUSTER_NAME%"=="" set CLUSTER_NAME=hello-task-cluster

echo ================================================
echo STEP 4: Create ECS Cluster
echo ================================================
echo Region: %AWS_REGION%
echo Cluster: %CLUSTER_NAME%
echo ================================================
echo.

aws ecs create-cluster ^
    --cluster-name %CLUSTER_NAME% ^
    --region %AWS_REGION% ^
    --capacity-providers FARGATE FARGATE_SPOT ^
    --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS: ECS cluster created!
    echo Cluster: %CLUSTER_NAME%
    echo ================================================
    echo.
    echo Next Step: Run 5-create-task-role.cmd %AWS_REGION%
) else (
    echo.
    echo ================================================
    echo ERROR: Failed to create ECS cluster
    echo NOTE: Cluster may already exist
    echo ================================================
    echo.
    echo Next Step: Run 5-create-task-role.cmd %AWS_REGION%
)
