@echo off
REM Build Docker image for HelloEKS application

echo Building Docker image...
docker build -t hello-eks:latest .

if %errorlevel% equ 0 (
    echo.
    echo Docker image built successfully!
    echo Image: hello-eks:latest
) else (
    echo.
    echo Failed to build Docker image.
    exit /b 1
)
