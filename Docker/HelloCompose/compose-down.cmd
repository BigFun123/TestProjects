@echo off
echo Stopping and removing Docker Compose services...
docker-compose down
if %errorlevel% equ 0 (
    echo.
    echo Services stopped and removed successfully!
) else (
    echo.
    echo Failed to stop services!
)
pause
