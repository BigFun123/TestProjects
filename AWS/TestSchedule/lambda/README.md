# Lambda HTTP Request Function

This AWS Lambda function makes an HTTPS GET request to `https://myalb.elb.eu-west-2.amazonaws.com` using Node.js 20's built-in `https` module.

## Setup
1. No dependencies needed (uses built-in modules).
2. Zip the contents: `zip -r lambda-function.zip .`
3. Upload to AWS Lambda via Console or CLI.

## Lambda Configuration
- **Runtime**: Node.js 20.x
- **Handler**: index.handler
- **Timeout**: Increase if needed (default 3s may not suffice for HTTP calls)
- **Permissions**: Ensure the Lambda has internet access (e.g., via NAT Gateway if in VPC).

## Deployment via CLI
```bash
aws lambda create-function --function-name MyLambdaFunction \
  --runtime nodejs20.x \
  --role arn:aws:iam::your-account-id:role/lambda-role \
  --handler index.handler \
  --zip-file fileb://lambda-function.zip
```