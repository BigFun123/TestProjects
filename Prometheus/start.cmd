@echo off
echo Starting Prometheus and Grafana...
docker-compose up -d
echo.
echo Services started:
echo - Prometheus: http://localhost:9090
echo - Grafana: http://localhost:3000 (admin/admin)
echo.
echo Starting .NET application...
dotnet run
