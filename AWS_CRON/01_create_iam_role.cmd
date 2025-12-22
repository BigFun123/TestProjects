@echo off
REM 1. Create an IAM role for Lambda with basic execution and CloudWatch permissions.
REM Explanation: This role allows Lambda to run and log output.
aws iam create-role --role-name LambdaBasicRole --assume-role-policy-document file://trust-policy.json
aws iam attach-role-policy --role-name LambdaBasicRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam attach-role-policy --role-name LambdaBasicRole --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
pause