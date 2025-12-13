@echo off
REM Test locally with Docker Compose

echo ======================================
echo Local Docker Testing
echo ======================================
echo.

if not exist docker-compose.yml (
    echo ERROR: docker-compose.yml not found
    pause
    exit /b 1
)

echo Select an action:
echo 1. Start services (build and run)
echo 2. Start services (without rebuild)
echo 3. Run scheduler only (API must be running)
echo 4. Stop all services
echo 5. View logs
echo 6. Remove containers and volumes
echo 7. Exit
echo.
set /p choice=Enter choice (1-7): 

if "%choice%"=="1" goto build_run
if "%choice%"=="2" goto run
if "%choice%"=="3" goto run_scheduler
if "%choice%"=="4" goto stop
if "%choice%"=="5" goto logs
if "%choice%"=="6" goto cleanup
if "%choice%"=="7" goto end

:build_run
echo.
echo Building and starting services...
docker-compose up --build
goto end

:run
echo.
echo Starting services...
docker-compose up
goto end

:run_scheduler
echo.
echo Running scheduler only...
docker-compose up ekstaskscheduler
goto end

:stop
echo.
echo Stopping services...
docker-compose down
echo.
echo Services stopped.
pause
goto menu

:logs
echo.
echo Select logs to view:
echo 1. API logs
echo 2. Scheduler logs
echo 3. All logs
echo.
set /p log_choice=Enter choice (1-3): 

if "%log_choice%"=="1" docker-compose logs ekswebapi
if "%log_choice%"=="2" docker-compose logs ekstaskscheduler
if "%log_choice%"=="3" docker-compose logs
echo.
pause
goto menu

:cleanup
echo.
echo Removing containers and volumes...
docker-compose down -v
echo.
echo Cleanup complete.
pause
goto menu

:menu
echo.
echo Press any key to return to menu...
pause >nul
cls
goto choice

:end
