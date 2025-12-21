@echo off
echo Building Docker Compose services...
docker-compose build
if %errorlevel% equ 0 (
    echo.
    echo Build completed successfully!
    echo Use compose-up.cmd to start the services
) else (
    echo.
    echo Build failed!
)
pause
