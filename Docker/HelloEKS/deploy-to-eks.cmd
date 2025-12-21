@echo off
REM Deploy HelloEKS application to Amazon EKS
REM Prerequisites:
REM   - kubectl installed and configured
REM   - EKS cluster created and kubeconfig configured
REM   - Docker image pushed to ECR
REM
REM Usage: deploy-to-eks.cmd <aws-account-id> <aws-region> [repository-name]
REM Example: deploy-to-eks.cmd 123456789012 us-east-1 hello-eks

if "%1"=="" (
    echo Error: AWS Account ID is required
    echo Usage: deploy-to-eks.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: deploy-to-eks.cmd 123456789012 us-east-1 hello-eks
    exit /b 1
)

if "%2"=="" (
    echo Error: AWS Region is required
    echo Usage: deploy-to-eks.cmd ^<aws-account-id^> ^<aws-region^> [repository-name]
    echo Example: deploy-to-eks.cmd 123456789012 us-east-1 hello-eks
    exit /b 1
)

set AWS_ACCOUNT_ID=%1
set AWS_REGION=%2
set REPOSITORY_NAME=%3
if "%REPOSITORY_NAME%"=="" set REPOSITORY_NAME=hello-eks
set IMAGE_URI=%AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/%REPOSITORY_NAME%:latest

echo ================================================
echo Deploying to Amazon EKS
echo ================================================
echo Image URI: %IMAGE_URI%
echo ================================================
echo.

echo Step 1: Update deployment.yaml with image URI...
powershell -Command "(Get-Content deployment.yaml) -replace '<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/hello-eks:latest', '%IMAGE_URI%' | Set-Content deployment-temp.yaml"
if %errorlevel% neq 0 (
    echo Failed to update deployment file
    exit /b 1
)
echo.

echo Step 2: Apply deployment to EKS cluster...
kubectl apply -f deployment-temp.yaml
if %errorlevel% neq 0 (
    echo Failed to deploy to EKS
    del deployment-temp.yaml
    exit /b 1
)
echo.

echo Step 3: Clean up temporary file...
del deployment-temp.yaml
echo.

echo ================================================
echo Deployment completed successfully!
echo ================================================
echo.
echo View deployment status:
echo   kubectl get deployments
echo   kubectl get pods
echo.
echo View logs:
echo   kubectl logs -l app=hello-eks -f
