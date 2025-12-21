@echo off
REM Step 1: Build the Docker image locally
REM This creates a containerized version of the HelloTask application

echo ================================================
echo STEP 1: Build Docker Image
echo ================================================
echo.

echo Building Docker image for HelloTask...
docker build -t hello-task:latest .

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo SUCCESS: Docker image built successfully!
    echo Image: hello-task:latest
    echo ================================================
    echo.
    echo Next Step: Run 2-create-ecr-repo.cmd
) else (
    echo.
    echo ================================================
    echo ERROR: Failed to build Docker image
    echo ================================================
    exit /b 1
)
