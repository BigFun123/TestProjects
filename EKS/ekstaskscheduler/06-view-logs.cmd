@echo off
REM View logs from deployed services

echo ======================================
echo EKS Scheduler Logs
echo ======================================
echo.

:menu
echo Select logs to view:
echo 1. API Logs (ekswebapi)
echo 2. Scheduler Logs (latest job)
echo 3. All Scheduler Jobs
echo 4. CronJob Status
echo 5. All Pods Status
echo 6. Exit
echo.
set /p choice=Enter choice (1-6): 

if "%choice%"=="1" goto api_logs
if "%choice%"=="2" goto scheduler_logs
if "%choice%"=="3" goto all_jobs
if "%choice%"=="4" goto cronjob_status
if "%choice%"=="5" goto pods_status
if "%choice%"=="6" goto end

:api_logs
echo.
echo ======================================
echo API Logs (Press Ctrl+C to stop)
echo ======================================
kubectl logs -n eks-scheduler -l app=ekswebapi --tail=50 -f
goto menu

:scheduler_logs
echo.
echo ======================================
echo Latest Scheduler Job Logs
echo ======================================
kubectl logs -n eks-scheduler -l app=api-scheduler --tail=100
echo.
pause
goto menu

:all_jobs
echo.
echo ======================================
echo All Scheduler Jobs
echo ======================================
kubectl get jobs -n eks-scheduler
echo.
echo Enter job name to view logs (or press Enter to skip):
set /p job_name=
if not "%job_name%"=="" (
    echo.
    kubectl logs -n eks-scheduler job/%job_name%
    echo.
    pause
)
goto menu

:cronjob_status
echo.
echo ======================================
echo CronJob Status
echo ======================================
kubectl get cronjobs -n eks-scheduler
echo.
echo Detailed CronJob info:
kubectl describe cronjob api-scheduler-cronjob -n eks-scheduler
echo.
pause
goto menu

:pods_status
echo.
echo ======================================
echo All Pods Status
echo ======================================
kubectl get pods -n eks-scheduler
echo.
pause
goto menu

:end
echo.
echo Goodbye!
