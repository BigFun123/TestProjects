@echo off
REM Check the status of Kubernetes deployment
echo ===================================
echo Kubernetes Status
echo ===================================

echo.
echo Deployments:
kubectl get deployments

echo.
echo Pods:
kubectl get pods

echo.
echo Services:
kubectl get services

echo.
echo HPA Status:
kubectl get hpa

echo.
echo To get logs from a pod:
echo kubectl logs POD_NAME
