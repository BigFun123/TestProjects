@echo off
REM Helper: Get Default VPC Subnet IDs
REM This helps you find the subnet IDs needed for step 8
REM
REM Usage: get-subnet-ids.cmd <aws-region>
REM Example: get-subnet-ids.cmd us-east-1

if "%1"=="" (
    echo ERROR: AWS Region is required
    echo.
    echo Usage: get-subnet-ids.cmd ^<aws-region^>
    echo Example: get-subnet-ids.cmd us-east-1
    exit /b 1
)

set AWS_REGION=%1

echo ================================================
echo Finding Default VPC Subnets
echo ================================================
echo Region: %AWS_REGION%
echo ================================================
echo.

echo Default VPC ID:
aws ec2 describe-vpcs --region %AWS_REGION% --filters "Name=is-default,Values=true" --query "Vpcs[0].VpcId" --output text
echo.

echo Subnet IDs (copy these for step 8):
aws ec2 describe-subnets --region %AWS_REGION% --filters "Name=default-for-az,Values=true" --query "Subnets[*].[SubnetId,AvailabilityZone]" --output table
echo.

echo Default Security Group ID (copy this for step 8):
aws ec2 describe-security-groups --region %AWS_REGION% --filters "Name=group-name,Values=default" "Name=vpc-id,Values=$(aws ec2 describe-vpcs --region %AWS_REGION% --filters Name=is-default,Values=true --query Vpcs[0].VpcId --output text)" --query "SecurityGroups[0].GroupId" --output text
echo.

echo ================================================
echo Copy these values for step 8
echo ================================================
