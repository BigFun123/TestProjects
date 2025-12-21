@echo off
REM View logs from HelloEKS pods in EKS cluster

echo Streaming logs from hello-eks pods...
echo Press Ctrl+C to stop
echo.

kubectl logs -l app=hello-eks -f --tail=50
