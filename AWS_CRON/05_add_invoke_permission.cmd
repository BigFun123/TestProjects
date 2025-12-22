@echo off
REM 5. Grant EventBridge permission to invoke your Lambda function.
REM Explanation: This step allows the scheduled rule to trigger Lambda.
aws lambda add-permission --function-name HelloCronLambda --statement-id EventBridgeInvoke --action "lambda:InvokeFunction" --principal events.amazonaws.com --source-arn <RULE_ARN>
pause