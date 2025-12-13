@echo off
REM Login to Amazon ECR

if not exist config.txt (
    echo ERROR: config.txt not found. Please run 01-setup-ecr.cmd first.
    pause
    exit /b 1
)

for /f "tokens=1,2 delims==" %%a in (config.txt) do (
    if "%%a"=="AWS_REGION" set AWS_REGION=%%b
    if "%%a"=="ECR_REPO" set ECR_REPO=%%b
)

echo ======================================
echo Logging in to Amazon ECR
echo ======================================
echo Region: %AWS_REGION%
echo Repository: %ECR_REPO%
echo.

aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_REPO%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Successfully logged in to ECR
    echo.
    echo Next step: Run 03-build-push-images.cmd to build and push images
) else (
    echo.
    echo ✗ Failed to login to ECR
    echo Please check your AWS credentials and try again.
)

echo.
pause
