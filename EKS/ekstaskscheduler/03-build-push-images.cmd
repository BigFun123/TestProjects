@echo off
REM Build and push Docker images to ECR

if not exist config.txt (
    echo ERROR: config.txt not found. Please run 01-setup-ecr.cmd first.
    pause
    exit /b 1
)

for /f "tokens=1,2 delims==" %%a in (config.txt) do (
    if "%%a"=="ECR_REPO" set ECR_REPO=%%b
)

echo ======================================
echo Building and Pushing Docker Images
echo ======================================
echo Repository: %ECR_REPO%
echo.

echo ======================================
echo Building ekswebapi...
echo ======================================
cd ..\ekswebapi
docker build -t ekswebapi .
if %ERRORLEVEL% NEQ 0 (
    echo ✗ Failed to build ekswebapi
    pause
    exit /b 1
)
echo ✓ ekswebapi built successfully
echo.

echo Tagging ekswebapi...
docker tag ekswebapi:latest %ECR_REPO%/ekswebapi:latest
echo ✓ Tagged
echo.

echo Pushing ekswebapi to ECR...
docker push %ECR_REPO%/ekswebapi:latest
if %ERRORLEVEL% NEQ 0 (
    echo ✗ Failed to push ekswebapi
    pause
    exit /b 1
)
echo ✓ ekswebapi pushed successfully
echo.

echo ======================================
echo Building ekstaskscheduler...
echo ======================================
cd ..\ekstaskscheduler
docker build -t ekstaskscheduler .
if %ERRORLEVEL% NEQ 0 (
    echo ✗ Failed to build ekstaskscheduler
    pause
    exit /b 1
)
echo ✓ ekstaskscheduler built successfully
echo.

echo Tagging ekstaskscheduler...
docker tag ekstaskscheduler:latest %ECR_REPO%/ekstaskscheduler:latest
echo ✓ Tagged
echo.

echo Pushing ekstaskscheduler to ECR...
docker push %ECR_REPO%/ekstaskscheduler:latest
if %ERRORLEVEL% NEQ 0 (
    echo ✗ Failed to push ekstaskscheduler
    pause
    exit /b 1
)
echo ✓ ekstaskscheduler pushed successfully
echo.

echo ======================================
echo ✓ All images built and pushed successfully!
echo ======================================
echo.
echo Next step: Run 04-update-k8s-yaml.cmd to update Kubernetes manifest
echo.
pause
