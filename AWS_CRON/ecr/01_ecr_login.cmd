@echo off
REM 1. Authenticate Docker to your AWS ECR registry.
REM Explanation: This logs Docker in so you can push images to ECR.
aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com
pause