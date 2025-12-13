@echo off
REM Manually trigger a CronJob for testing

echo ======================================
echo Manual CronJob Trigger
echo ======================================
echo.

echo This will create a one-time job from the CronJob for testing.
echo.

set job_name=manual-test-%date:~-4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%
set job_name=%job_name: =0%

echo Creating job: %job_name%
kubectl create job --from=cronjob/api-scheduler-cronjob %job_name% -n eks-scheduler

if %ERRORLEVEL% EQU 0 (
    echo ✓ Job created successfully
    echo.
    echo Waiting for job to start...
    timeout /t 3 >nul
    echo.
    
    echo Job status:
    kubectl get job %job_name% -n eks-scheduler
    echo.
    
    echo Pod status:
    kubectl get pods -n eks-scheduler -l job-name=%job_name%
    echo.
    
    echo Do you want to view the logs? (Y/N)
    set /p view_logs=
    if /i "%view_logs%"=="Y" (
        echo.
        echo Waiting for pod to be ready...
        kubectl wait --for=condition=ready pod -l job-name=%job_name% -n eks-scheduler --timeout=60s
        echo.
        echo ======================================
        echo Job Logs
        echo ======================================
        kubectl logs -n eks-scheduler -l job-name=%job_name% --tail=100
    )
) else (
    echo ✗ Failed to create job
)

echo.
pause
