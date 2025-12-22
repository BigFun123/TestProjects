@echo off
REM 4. Tag your Docker image for ECR.
REM Explanation: This tags the image with your ECR repo URI.
docker tag hellocron 984778981719.dkr.ecr.eu-west-1.amazonaws.com/hellocron:latest
pause