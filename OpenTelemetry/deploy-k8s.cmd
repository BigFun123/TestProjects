@echo off
setlocal enabledelayedexpansion

REM Load configuration
if not exist aws-config.cmd (
    echo ERROR: aws-config.cmd not found!
    echo Please copy aws-config.template.cmd to aws-config.cmd and configure it.
    exit /b 1
)
call aws-config.cmd

set CLUSTER_NAME=%1

if "%CLUSTER_NAME%"=="" (
    set CLUSTER_NAME=%EKS_CLUSTER_NAME%
)

echo ========================================
echo Deploying OpenTelemetry to Kubernetes
echo Cluster: %CLUSTER_NAME%
echo ========================================
echo.

echo [1/5] Adding OpenTelemetry Helm repository...
%HELM_PATH% repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
%HELM_PATH% repo update

echo.
echo [2/5] Creating namespace...
kubectl create namespace %K8S_NAMESPACE% --dry-run=client -o yaml | kubectl apply -f -

echo.
echo [3/5] Installing OpenTelemetry Collector...
%HELM_PATH% upgrade --install opentelemetry-collector ^
  open-telemetry/opentelemetry-collector ^
  -f kubernetes/helm-values.yaml ^
  -n %K8S_NAMESPACE% ^
  --wait

echo.
echo [4/5] Waiting for collector to be ready...
kubectl wait --for=condition=available --timeout=120s ^
  deployment/opentelemetry-collector -n %K8S_NAMESPACE%

echo.
echo [5/5] Deployment Status:
kubectl get pods -n %K8S_NAMESPACE%
kubectl get svc -n %K8S_NAMESPACE%

echo.
echo ========================================
echo OpenTelemetry Collector Deployed!
echo ========================================
echo.
echo Next steps:
echo 1. Build and push your Docker image
echo 2. Update kubernetes/sample-app-deployment.yaml with your image
echo 3. Run: kubectl apply -f kubernetes/sample-app-deployment.yaml
echo.
echo Check AWS X-Ray Console: https://console.aws.amazon.com/xray/
echo Check CloudWatch Logs:   https://console.aws.amazon.com/cloudwatch/
echo.
