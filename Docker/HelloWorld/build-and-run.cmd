@echo off
echo Building and running Docker container...
echo.
echo Step 1: Building image...
docker build -t hello-world-app .
echo.
echo Step 2: Running container...
docker run --rm hello-world-app
echo.
pause
