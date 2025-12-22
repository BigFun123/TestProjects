@echo off
REM 5. Push your Docker image to ECR.
REM Explanation: This uploads your image to the ECR repository.
docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/hellocron:latest
pause