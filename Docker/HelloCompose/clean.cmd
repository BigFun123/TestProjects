@echo off
echo Cleaning up Docker Compose resources...
echo.
echo Stopping and removing containers...
docker-compose down

echo Removing Docker images...
docker rmi hellocompose:latest 2>nul

echo Removing dangling images...
docker image prune -f

if %errorlevel% equ 0 (
    echo.
    echo Cleanup completed successfully!
) else (
    echo.
    echo Some cleanup operations may have failed.
)
pause
