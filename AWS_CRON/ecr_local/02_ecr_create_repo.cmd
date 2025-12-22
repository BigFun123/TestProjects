@echo off
REM 2. Create an ECR repository for your image (if it doesn't exist).
REM Explanation: This creates a new ECR repo for storing your Docker image.
aws ecr create-repository --repository-name hellocron --region <AWS_REGION>
pause