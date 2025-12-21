@echo off
REM Step 7: Create EventBridge (CloudWatch Events) Rule
REM This creates the schedule that triggers the ECS task every hour
REM
REM Usage: 7-create-eventbridge-rule.cmd <aws-region> [rule-name]
REM Example: 7-create-eventbridge-rule.cmd us-east-1 hello-task-hourly

if "%1"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: 7-create-eventbridge-rule.cmd ^<aws-region^> [rule-name]
    echo Example: 7-create-eventbridge-rule.cmd us-east-1 hello-task-hourly
    exit /b 1
)

set AWS_REGION=%1
set RULE_NAME=%2
if "%RULE_NAME%"=="" set RULE_NAME=hello-task-hourly

echo ================================================
echo STEP 7: Create EventBridge Rule
echo ================================================
echo Region: %AWS_REGION%
echo Rule Name: %RULE_NAME%
echo Schedule: Every hour (cron: 0 * * * ? *)
echo ================================================
echo.

echo Creating EventBridge rule...
aws events put-rule ^
    --name %RULE_NAME% ^
    --schedule-expression "cron(0 * * * ? *)" ^
    --state ENABLED ^
    --description "Runs HelloTask ECS task every hour" ^
    --region %AWS_REGION%

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS: EventBridge rule created!
    echo Rule: %RULE_NAME%
    echo Schedule: Every hour at minute 0
    echo ================================================
    echo.
    echo Next Step: Run 8-create-ecs-target.cmd (AWS_ACCOUNT_ID) %AWS_REGION%
) else (
    echo.
    echo ================================================
    echo ERROR: Failed to create EventBridge rule
    echo ================================================
    exit /b 1
)
