@echo off

REM Load configuration
if not exist aws-config.cmd (
    echo ERROR: aws-config.cmd not found!
    echo Please copy aws-config.template.cmd to aws-config.cmd and configure it.
    exit /b 1
)
call aws-config.cmd

echo ===============================================
echo AWS RESOURCES CHECK
echo ===============================================
echo.
echo Checking what resources currently exist...
echo.

echo ===============================================
echo KUBERNETES RESOURCES
echo ===============================================
echo.
echo Sample Application:
kubectl get deployment otel-sample-app -n default 2>nul
if %errorlevel% equ 0 (
    echo [EXISTS] Sample application deployment
) else (
    echo [NOT FOUND] Sample application
)

kubectl get svc otel-sample-app -n default 2>nul
if %errorlevel% equ 0 (
    echo [EXISTS] Sample application service
) else (
    echo [NOT FOUND] Service
)

echo.
echo OpenTelemetry Collector:
kubectl get deployment otel-collector -n %K8S_NAMESPACE% 2>nul
if %errorlevel% equ 0 (
    echo [EXISTS] Collector deployment
) else (
    echo [NOT FOUND] Collector
)

kubectl get namespace %K8S_NAMESPACE% 2>nul
if %errorlevel% equ 0 (
    echo [EXISTS] Observability namespace
) else (
    echo [NOT FOUND] Namespace
)

echo.
echo ===============================================
echo IAM RESOURCES
echo ===============================================
echo.

aws iam get-role --role-name %IAM_ROLE_NAME% 2>nul
if %errorlevel% equ 0 (
    echo [EXISTS] IAM Role: %IAM_ROLE_NAME%
) else (
    echo [NOT FOUND] IAM Role
)

aws iam get-policy --policy-arn arn:aws:iam::%AWS_ACCOUNT_ID%:policy/%IAM_POLICY_NAME% 2>nul
if %errorlevel% equ 0 (
    echo [EXISTS] IAM Policy: %IAM_POLICY_NAME%
) else (
    echo [NOT FOUND] IAM Policy
)

echo.
echo ===============================================
echo ECR REPOSITORY
echo ===============================================
echo.

aws ecr describe-repositories --repository-names %ECR_REPOSITORY_NAME% --region %AWS_REGION% 2>nul
if %errorlevel% equ 0 (
    echo [EXISTS] ECR Repository: %ECR_REPOSITORY_NAME%
    echo.
    echo Images in repository:
    aws ecr list-images --repository-name %ECR_REPOSITORY_NAME% --region %AWS_REGION% --query "imageIds[*].[imageTag]" --output table
) else (
    echo [NOT FOUND] ECR Repository
)

echo.
echo ===============================================
echo EKS CLUSTER
echo ===============================================
echo.

aws eks describe-cluster --name %EKS_CLUSTER_NAME% --region %AWS_REGION% --query "cluster.{Name:name,Status:status,Version:version,CreatedAt:createdAt}" --output table 2>nul
if %errorlevel% equ 0 (
    echo.
    echo [EXISTS] EKS Cluster: %EKS_CLUSTER_NAME%
    echo.
    echo Nodes:
    kubectl get nodes
) else (
    echo [NOT FOUND] EKS Cluster
)

echo.
echo ===============================================
echo CLOUDWATCH RESOURCES
echo ===============================================
echo.
echo Log Groups:
aws logs describe-log-groups --log-group-name-prefix /aws/eks/%EKS_CLUSTER_NAME% --region %AWS_REGION% --query "logGroups[*].[logGroupName,storedBytes]" --output table 2>nul

echo.
echo Custom Metrics (OpenTelemetry):
aws cloudwatch list-metrics --namespace "OpenTelemetry/App" --region %AWS_REGION% --query "Metrics[*].MetricName" --output table 2>nul

echo.
echo ===============================================
echo ESTIMATED MONTHLY COSTS
echo ===============================================
echo.
echo Checking current month costs...
aws ce get-cost-and-usage --time-period Start=2025-11-01,End=2025-11-30 --granularity MONTHLY --metrics BlendedCost --group-by Type=SERVICE --region %AWS_REGION% --query "ResultsByTime[0].Groups[?Metrics.BlendedCost.Amount>'0']" --output table 2>nul

echo.
echo ===============================================
echo SUMMARY COMPLETE
echo ===============================================
echo.
pause
