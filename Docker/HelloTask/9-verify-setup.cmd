@echo off
REM Step 9: Verify the Complete Setup
REM This checks that all components are properly configured
REM
REM Usage: 9-verify-setup.cmd <aws-region>
REM Example: 9-verify-setup.cmd us-east-1

if "%1"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: 9-verify-setup.cmd ^<aws-region^>
    echo Example: 9-verify-setup.cmd us-east-1
    exit /b 1
)

set AWS_REGION=%1
set RULE_NAME=hello-task-hourly
set CLUSTER_NAME=hello-task-cluster
set TASK_DEFINITION=hello-task

echo ================================================
echo STEP 9: Verify Setup
echo ================================================
echo Region: %AWS_REGION%
echo ================================================
echo.

echo Checking EventBridge rule...
aws events describe-rule --name %RULE_NAME% --region %AWS_REGION% --query "State" --output text
if %errorlevel% equ 0 (
    echo   Rule status: OK
) else (
    echo   ERROR: Rule not found
)
echo.

echo Checking EventBridge targets...
aws events list-targets-by-rule --rule %RULE_NAME% --region %AWS_REGION% --query "Targets[0].Id" --output text
if %errorlevel% equ 0 (
    echo   Target status: OK
) else (
    echo   ERROR: Target not configured
)
echo.

echo Checking ECS cluster...
aws ecs describe-clusters --clusters %CLUSTER_NAME% --region %AWS_REGION% --query "clusters[0].status" --output text
if %errorlevel% equ 0 (
    echo   Cluster status: OK
) else (
    echo   ERROR: Cluster not found
)
echo.

echo Checking task definition...
aws ecs describe-task-definition --task-definition %TASK_DEFINITION% --region %AWS_REGION% --query "taskDefinition.family" --output text
if %errorlevel% equ 0 (
    echo   Task definition status: OK
) else (
    echo   ERROR: Task definition not found
)
echo.

echo ================================================
echo Verification Complete
echo ================================================
echo.
echo Next scheduled run: Check EventBridge console for next invocation time
echo.
echo Useful commands:
echo   - View task runs: aws ecs list-tasks --cluster %CLUSTER_NAME% --region %AWS_REGION%
echo   - View logs: Check CloudWatch Logs group: /ecs/hello-task
echo   - Disable schedule: aws events disable-rule --name %RULE_NAME% --region %AWS_REGION%
echo   - Enable schedule: aws events enable-rule --name %RULE_NAME% --region %AWS_REGION%
