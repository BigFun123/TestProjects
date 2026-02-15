# SQS Queue with Lambda and CloudWatch Alarm

This Terraform configuration creates an SQS queue that triggers a Lambda function when messages arrive, with a CloudWatch alarm for monitoring.

## Prerequisites

- Terraform installed
- AWS CLI configured with appropriate credentials
- Python 3.11 (for Lambda function)

## Setup

1. Create the Lambda deployment package:
```bash
zip lambda_function.zip lambda_function.py
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the plan:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

## Resources Created

- SQS Queue
- Lambda Function (triggered by SQS)
- IAM Role and Policy for Lambda
- Lambda Event Source Mapping
- CloudWatch Alarm (monitors queue message count)

## Testing

Send a test message to the queue:
```bash
aws sqs send-message --queue-url <queue-url> --message-body "Test message"
```

## Cleanup

```bash
terraform destroy
```
