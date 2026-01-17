# Scheduled Lambda with AWS EventBridge (Terraform, .NET 8)

This project contains a .NET 8 AWS Lambda function triggered by an EventBridge schedule every 24 hours. Infrastructure is managed with Terraform.

## Structure
- `ScheduledLambda/` - .NET 8 Lambda function code
- `terraform/` - Terraform scripts for AWS resources

## Prerequisites
- [.NET 8 SDK](https://dotnet.microsoft.com/en-us/download)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Terraform](https://www.terraform.io/downloads)
- AWS credentials configured (e.g., via `aws configure`)

## Build and Deploy

1. **Build Lambda Package**
   ```sh
   dotnet build ScheduledLambda
   dotnet lambda package --project-location ScheduledLambda --output-package lambda.zip
   ```

2. **Deploy with Terraform**
   ```sh
   cd terraform
   terraform init
   terraform apply -var="lambda_package=../lambda.zip"
   ```

## Lambda Handler
- The Lambda entry point is `ScheduledLambda::ScheduledLambda.Function::FunctionHandler`.
- Modify the function logic in `ScheduledLambda/Function.cs` as needed.

## EventBridge Schedule
- The Lambda is triggered every 24 hours by an EventBridge rule (`rate(24 hours)`).

## Outputs
- Lambda function name
- EventBridge rule ARN

## Cleanup
To remove all resources:
```sh
cd terraform
terraform destroy -var="lambda_package=../lambda.zip"
```
