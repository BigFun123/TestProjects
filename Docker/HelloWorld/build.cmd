@echo off
echo Building Docker image...
docker build -t hello-world-app .
echo.
echo Build complete!
pause
