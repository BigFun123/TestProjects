@echo off
REM Stop and remove local Docker container
echo Stopping container...
docker stop helloworld-container

echo Removing container...
docker rm helloworld-container

echo Done!
