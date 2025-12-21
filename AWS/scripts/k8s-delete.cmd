@echo off
REM Delete all Kubernetes resources
echo ===================================
echo Delete Kubernetes Resources
echo ===================================

echo.
echo This will delete all resources. Continue? (Y/N)
set /p CONFIRM=
if /i not "%CONFIRM%"=="Y" (
    echo Cancelled.
    exit /b 0
)

echo.
echo Deleting resources...
kubectl delete -f k8s\hpa.yaml
kubectl delete -f k8s\service.yaml
kubectl delete -f k8s\deployment.yaml
kubectl delete -f k8s\configmap.yaml

echo.
echo All resources deleted!
