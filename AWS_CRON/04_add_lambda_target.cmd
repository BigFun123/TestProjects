@echo off
REM 4. Add Lambda as the target for the EventBridge rule.
REM Explanation: This connects the cron rule to your Lambda function.
aws events put-targets --rule HelloCronSchedule --targets "Id"="1","Arn"="<LAMBDA_ARN>"
pause