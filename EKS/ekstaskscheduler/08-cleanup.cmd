@echo off
REM Cleanup all EKS resources

echo ======================================
echo CLEANUP WARNING
echo ======================================
echo.
echo This will DELETE all resources in the eks-scheduler namespace:
echo - Namespace: eks-scheduler
echo - Deployment: ekswebapi
echo - Service: ekswebapi-service
echo - CronJob: api-scheduler-cronjob
echo - All jobs and pods
echo.
echo Are you sure you want to continue? (Y/N)
set /p confirm=

if /i not "%confirm%"=="Y" (
    echo.
    echo Cleanup cancelled.
    pause
    exit /b 0
)

echo.
echo ======================================
echo Deleting Resources
echo ======================================
echo.

echo Deleting namespace eks-scheduler...
kubectl delete namespace eks-scheduler

if %ERRORLEVEL% EQU 0 (
    echo ✓ Namespace deleted successfully
    echo.
    echo All resources have been removed.
    echo.
    echo Note: Docker images in ECR are NOT deleted.
    echo To delete ECR repositories, run 09-delete-ecr.cmd
) else (
    echo ✗ Failed to delete namespace
    echo You may need to delete resources manually.
)

echo.
pause
