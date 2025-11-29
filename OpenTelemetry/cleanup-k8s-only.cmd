@echo off

REM Load configuration
if not exist aws-config.cmd (
    echo ERROR: aws-config.cmd not found!
    echo Please copy aws-config.template.cmd to aws-config.cmd and configure it.
    exit /b 1
)
call aws-config.cmd

echo ===============================================
echo KUBERNETES-ONLY CLEANUP
echo ===============================================
echo.
echo This will DELETE only Kubernetes resources.
echo AWS resources (IAM, ECR, EKS Cluster) will remain.
echo.
echo Resources to be deleted:
echo - Sample application deployment and service
echo - OpenTelemetry Collector deployment
echo - Namespace: %K8S_NAMESPACE%
echo.

set /p CONFIRM="Continue? (type YES to confirm): "
if not "%CONFIRM%"=="YES" (
    echo Cancelled.
    exit /b 0
)

echo.
echo Deleting sample application...
kubectl delete -f kubernetes/sample-app-deployment.yaml
echo.

echo Waiting for LoadBalancer to be removed (30 seconds)...
timeout /t 30 /nobreak >nul

echo.
echo Deleting OpenTelemetry Collector...
kubectl delete -f kubernetes/otel-collector-deployment.yaml
echo.

echo Deleting observability namespace...
kubectl delete namespace %K8S_NAMESPACE% --timeout=60s
echo.

echo.
echo ===============================================
echo KUBERNETES CLEANUP COMPLETE
echo ===============================================
echo.
echo Remaining AWS resources:
echo - EKS Cluster (still incurring costs: $73/month)
echo - IAM Role and Policy (no cost)
echo - ECR Repository with images (minimal cost: ~$1/month)
echo.
echo To delete everything including the cluster, run:
echo   cleanup-aws.cmd
echo.
pause
