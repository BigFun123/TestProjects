@echo off
echo Building services with Docker Compose (without cache)...
docker-compose build --no-cache
if %errorlevel% equ 0 (
    echo.
    echo Starting services...
    docker-compose up -d
    if %errorlevel% equ 0 (
        echo.
        echo Build and start completed successfully!
        echo Use compose-logs.cmd to view logs
    )
) else (
    echo.
    echo Build failed!
)
pause
