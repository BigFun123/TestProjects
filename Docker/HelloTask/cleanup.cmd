@echo off
REM Helper: Cleanup - Delete All Resources
REM WARNING: This will delete all resources created by this project
REM
REM Usage: cleanup.cmd <aws-region>
REM Example: cleanup.cmd us-east-1

if "%1"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: cleanup.cmd ^<aws-region^>
    echo Example: cleanup.cmd us-east-1
    exit /b 1
)

set AWS_REGION=%1
set RULE_NAME=hello-task-hourly
set CLUSTER_NAME=hello-task-cluster
set TASK_DEFINITION=hello-task
set REPOSITORY_NAME=hello-task

echo ================================================
echo WARNING: This will delete all HelloTask resources
echo ================================================
echo Region: %AWS_REGION%
echo.
echo Resources to be deleted:
echo - EventBridge rule: %RULE_NAME%
echo - ECS cluster: %CLUSTER_NAME%
echo - Task definition: %TASK_DEFINITION%
echo - ECR repository: %REPOSITORY_NAME%
echo - IAM role: ecsTaskExecutionRole
echo - CloudWatch log group: /ecs/hello-task
echo ================================================
echo.
set /p CONFIRM="Type 'yes' to confirm deletion: "

if not "%CONFIRM%"=="yes" (
    echo Cleanup cancelled.
    exit /b 0
)

echo.
echo Starting cleanup...
echo.

echo Removing targets from EventBridge rule...
aws events remove-targets --rule %RULE_NAME% --ids "1" --region %AWS_REGION%
echo.

echo Deleting EventBridge rule...
aws events delete-rule --name %RULE_NAME% --region %AWS_REGION%
echo.

echo Deregistering task definitions...
for /f %%i in ('aws ecs list-task-definitions --family-prefix %TASK_DEFINITION% --region %AWS_REGION% --query "taskDefinitionArns[]" --output text') do (
    aws ecs deregister-task-definition --task-definition %%i --region %AWS_REGION%
)
echo.

echo Deleting ECS cluster...
aws ecs delete-cluster --cluster %CLUSTER_NAME% --region %AWS_REGION%
echo.

echo Deleting ECR repository...
aws ecr delete-repository --repository-name %REPOSITORY_NAME% --force --region %AWS_REGION%
echo.

echo Deleting CloudWatch log group...
aws logs delete-log-group --log-group-name /ecs/hello-task --region %AWS_REGION%
echo.

echo ================================================
echo Cleanup complete!
echo ================================================
echo.
echo Note: IAM role 'ecsTaskExecutionRole' was not deleted as it may be used by other tasks.
echo To delete it manually:
echo   aws iam detach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
echo   aws iam delete-role --role-name ecsTaskExecutionRole
