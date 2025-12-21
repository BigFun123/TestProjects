@echo off
echo Cleaning up Docker resources...
echo.
echo Removing hello-world-app image...
docker rmi hello-world-app
echo.
echo Cleaning up unused images and containers...
docker system prune -f
echo.
echo Cleanup complete!
pause
