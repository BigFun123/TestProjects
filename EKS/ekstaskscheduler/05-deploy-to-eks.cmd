@echo off
REM Deploy to EKS cluster

echo ======================================
echo Deploying to EKS Cluster
echo ======================================
echo.

echo Checking kubectl connection...
kubectl cluster-info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ✗ kubectl is not connected to a cluster
    echo Please configure kubectl for your EKS cluster first.
    echo.
    echo Example:
    echo aws eks update-kubeconfig --region your-region --name your-cluster-name
    pause
    exit /b 1
)

echo ✓ kubectl is connected
echo.

echo Current context:
kubectl config current-context
echo.

echo Applying Kubernetes manifests...
kubectl apply -f k8s-cronjob.yaml

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Deployment successful!
    echo.
    echo ======================================
    echo Deployment Status
    echo ======================================
    echo.
    
    echo Namespace:
    kubectl get namespace eks-scheduler
    echo.
    
    echo Deployments:
    kubectl get deployments -n eks-scheduler
    echo.
    
    echo Pods:
    kubectl get pods -n eks-scheduler
    echo.
    
    echo Services:
    kubectl get services -n eks-scheduler
    echo.
    
    echo CronJobs:
    kubectl get cronjobs -n eks-scheduler
    echo.
    
    echo ======================================
    echo Next Steps:
    echo ======================================
    echo - Run 06-view-logs.cmd to view logs
    echo - Run 07-manual-trigger.cmd to manually trigger a job
    echo - Run 08-cleanup.cmd to remove all resources
) else (
    echo.
    echo ✗ Deployment failed
    echo Please check the error messages above.
)

echo.
pause
