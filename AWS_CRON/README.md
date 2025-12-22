https://www.youtube.com/watch?v=1_AlV-FFxM8

# AWS_CRON HelloCron Example

This project demonstrates how to create a simple .NET 8 C# app that sends an HTTP request, and how to schedule it using AWS Lambda and EventBridge (cron).

## Project Structure
- `HelloCron/` — .NET 8 C# console app that sends an HTTP request.
- `01_create_iam_role.cmd` — Create IAM role for Lambda.
- `02_create_lambda_function.cmd` — Deploy app as Lambda function.
- `03_create_eventbridge_rule.cmd` — Create EventBridge cron rule.
- `04_add_lambda_target.cmd` — Add Lambda as EventBridge target.
- `05_add_invoke_permission.cmd` — Allow EventBridge to invoke Lambda.

## Where to Get Required Codes

### 1. ROLE_ARN
- **How to get:**
  - After running `01_create_iam_role.cmd`, go to the AWS Console > IAM > Roles.
  - Find the role named `LambdaBasicRole`.
  - Click the role and copy the **Role ARN** (e.g., `arn:aws:iam::123456789012:role/LambdaBasicRole`).
  - Replace `<ROLE_ARN>` in `02_create_lambda_function.cmd` with this value.

### 2. LAMBDA_ARN
- **How to get:**
  - After running `02_create_lambda_function.cmd`, go to AWS Console > Lambda > Functions.
  - Find your function (e.g., `HelloCronLambda`).
  - Click the function and copy the **Function ARN** (e.g., `arn:aws:lambda:us-east-1:123456789012:function:HelloCronLambda`).
  - Replace `<LAMBDA_ARN>` in `04_add_lambda_target.cmd` with this value.

### 3. RULE_ARN
- **How to get:**
  - After running `03_create_eventbridge_rule.cmd`, go to AWS Console > Amazon EventBridge > Rules.
  - Find the rule named `HelloCronSchedule`.
  - Click the rule and copy the **Rule ARN** (e.g., `arn:aws:events:us-east-1:123456789012:rule/HelloCronSchedule`).
  - Replace `<RULE_ARN>` in `05_add_invoke_permission.cmd` with this value.

## Notes
- You need the AWS CLI installed and configured with appropriate permissions.
- The .NET app must be published and zipped as `HelloCron.zip` before uploading to Lambda.
- Each `.cmd` file pauses after execution so you can review output and copy ARNs as needed.

---
This is a learning resource. Adjust names and regions as needed for your AWS account.
