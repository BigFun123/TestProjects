@echo off
REM Delete HelloEKS deployment from EKS cluster

echo Deleting HelloEKS deployment...
kubectl delete -f deployment.yaml

if %errorlevel% equ 0 (
    echo.
    echo Deployment deleted successfully!
) else (
    echo.
    echo Failed to delete deployment or deployment not found.
)
