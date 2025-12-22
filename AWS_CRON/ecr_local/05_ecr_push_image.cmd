@echo off
REM 5. Push your Docker image to ECR.
REM Explanation: This uploads your image to the ECR repository.
docker push 984778981719.dkr.ecr.eu-west-1.amazonaws.com/hellocron:latest
pause