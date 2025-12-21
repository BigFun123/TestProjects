@echo off
echo Viewing logs from Docker Compose services...
echo Press Ctrl+C to stop viewing logs
echo.
docker-compose logs -f
pause
