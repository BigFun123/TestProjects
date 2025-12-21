@echo off
echo Starting services with Docker Compose (without building)...
docker-compose up -d --no-build
if %errorlevel% equ 0 (
    echo.
    echo Services started successfully!
    echo Use compose-logs.cmd to view logs
    echo Use compose-down.cmd to stop services
) else (
    echo.
    echo Failed to start services!
    echo Try running compose-build.cmd first to build the image.
)
pause
