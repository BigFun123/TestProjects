@echo off
REM Get status of HelloEKS deployment and pods

echo ================================================
echo HelloEKS Deployment Status
echo ================================================
echo.

echo Deployments:
kubectl get deployments -l app=hello-eks
echo.

echo Pods:
kubectl get pods -l app=hello-eks
echo.

echo Pod Details:
kubectl describe pods -l app=hello-eks
