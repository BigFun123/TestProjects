@echo off

REM Load configuration
if not exist aws-config.cmd (
    echo ERROR: aws-config.cmd not found!
    echo Please copy aws-config.template.cmd to aws-config.cmd and configure it.
    exit /b 1
)
call aws-config.cmd

echo Tagging VPC subnets for ELB support...
echo.
echo NOTE: Update the SUBNETS variable below with your actual subnet IDs
echo.

REM Replace these with your actual subnet IDs
set "SUBNETS=subnet-EXAMPLE1 subnet-EXAMPLE2 subnet-EXAMPLE3"

echo Tagging subnets for internet-facing load balancers...
for %%s in (%SUBNETS%) do (
    echo Tagging %%s...
    aws ec2 create-tags --resources %%s --tags Key=kubernetes.io/role/elb,Value=1 --region %AWS_REGION%
)

echo.
echo ✅ Subnets tagged successfully!
echo The LoadBalancer should provision in a few moments.
echo.
