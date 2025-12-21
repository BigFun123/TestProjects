@echo off
REM Helper: View CloudWatch Logs
REM This displays recent logs from the scheduled task
REM
REM Usage: view-logs.cmd <aws-region>
REM Example: view-logs.cmd us-east-1

if "%1"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: view-logs.cmd ^<aws-region^>
    echo Example: view-logs.cmd us-east-1
    exit /b 1
)

set AWS_REGION=%1
set LOG_GROUP=/ecs/hello-task

echo ================================================
echo CloudWatch Logs for HelloTask
echo ================================================
echo Log Group: %LOG_GROUP%
echo Region: %AWS_REGION%
echo ================================================
echo.

echo Fetching recent log streams...
aws logs describe-log-streams ^
    --log-group-name %LOG_GROUP% ^
    --region %AWS_REGION% ^
    --order-by LastEventTime ^
    --descending ^
    --max-items 5 ^
    --query "logStreams[*].[logStreamName,lastEventTime]" ^
    --output table

echo.
echo To view logs from a specific stream, run:
echo aws logs get-log-events --log-group-name %LOG_GROUP% --log-stream-name ^<stream-name^> --region %AWS_REGION%
