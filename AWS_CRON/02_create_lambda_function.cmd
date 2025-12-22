@echo off
REM 2. Create a Lambda function using the published .NET app.
REM Explanation: This step uploads your HelloCron app as a Lambda function.
aws lambda create-function --function-name HelloCronLambda --runtime dotnet8 --role <ROLE_ARN> --handler HelloCron::HelloCron.Program::Main --zip-file fileb://HelloCron.zip
pause