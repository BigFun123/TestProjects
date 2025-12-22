@echo off
REM 1. Authenticate Docker to your AWS ECR registry.
REM Explanation: This logs Docker in so you can push images to ECR.
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 984778981719.dkr.ecr.eu-west-1.amazonaws.com
pause