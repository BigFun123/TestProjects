@echo off
REM Build and run Docker container locally
echo Building Docker image...
docker build -t helloworld-app:latest .

if %ERRORLEVEL% EQU 0 (
    echo Docker build successful!
    echo Starting container on port 8080...
    docker run -d -p 8080:8080 --name helloworld-container helloworld-app:latest
    echo.
    echo Container started! Access the app at:
    echo http://localhost:8080
    echo.
    echo To view logs: docker logs helloworld-container
    echo To stop: docker stop helloworld-container
    echo To remove: docker rm helloworld-container
) else (
    echo Docker build failed!
    exit /b 1
)
