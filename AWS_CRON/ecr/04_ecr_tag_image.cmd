@echo off
REM 4. Tag your Docker image for ECR.
REM Explanation: This tags the image with your ECR repo URI.
docker tag hellocron <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/hellocron:latest
pause