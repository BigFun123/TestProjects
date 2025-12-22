@echo off
REM 3. Create an EventBridge rule to trigger Lambda on a cron schedule.
REM Explanation: This sets up the AWS cron job to invoke your Lambda function.
aws events put-rule --name HelloCronSchedule --schedule-expression "cron(0 12 * * ? *)"
pause