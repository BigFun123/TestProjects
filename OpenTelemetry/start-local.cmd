@echo off
echo Starting OpenTelemetry Local Environment...
echo.

echo [1/3] Starting Docker Compose services...
docker-compose up -d

echo.
echo [2/3] Waiting for services to be ready...
timeout /t 10 /nobreak > nul

echo.
echo [3/3] Services Status:
docker-compose ps

echo.
echo ========================================
echo OpenTelemetry Environment is Ready!
echo ========================================
echo.
echo Sample App:      http://localhost:5000
echo Jaeger UI:       http://localhost:16686
echo Collector Stats: http://localhost:8888/metrics
echo.
echo Test the app with:
echo   curl http://localhost:5000/
echo   curl http://localhost:5000/api/users/1
echo.
echo View traces in Jaeger UI at http://localhost:16686
echo.
