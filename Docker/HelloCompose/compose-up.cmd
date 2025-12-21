@echo off
echo Building and starting services with Docker Compose...
docker-compose up -d
if %errorlevel% equ 0 (
    echo.
    echo Services started successfully!
    echo Use compose-logs.cmd to view logs
    echo Use compose-down.cmd to stop services
) else (
    echo.
    echo Failed to start services!
)
pause
