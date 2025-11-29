@echo off

REM Load configuration
if not exist aws-config.cmd (
    echo ERROR: aws-config.cmd not found!
    echo Please copy aws-config.template.cmd to aws-config.cmd and configure it.
    exit /b 1
)
call aws-config.cmd

echo ===============================================
echo AWS EKS OPENTELEMETRY CLEANUP SCRIPT
echo ===============================================
echo.
echo This will DELETE all resources created for the OpenTelemetry setup.
echo.
echo Resources to be deleted:
echo - Sample application deployment and service
echo - OpenTelemetry Collector deployment
echo - Kubernetes namespace: %K8S_NAMESPACE%
echo - IAM role: %IAM_ROLE_NAME%
echo - IAM policy: %IAM_POLICY_NAME%
echo - ECR repository: %ECR_REPOSITORY_NAME%
echo - EKS cluster: %EKS_CLUSTER_NAME%
echo.
set /p CONFIRM="Are you sure you want to proceed? (type YES to confirm): "
if not "%CONFIRM%"=="YES" (
    echo Cleanup cancelled.
    exit /b 0
)

echo.
echo ===============================================
echo STEP 1: Deleting Kubernetes Resources
echo ===============================================
echo.

echo Deleting sample application...
kubectl delete -f kubernetes/sample-app-deployment.yaml 2>nul
if %errorlevel% equ 0 (
    echo [OK] Sample application deleted
) else (
    echo [SKIP] Sample application not found or already deleted
)

echo.
echo Deleting OpenTelemetry Collector...
kubectl delete -f kubernetes/otel-collector-deployment.yaml 2>nul
if %errorlevel% equ 0 (
    echo [OK] OpenTelemetry Collector deleted
) else (
    echo [SKIP] Collector not found or already deleted
)

echo.
echo Waiting for LoadBalancer to be removed (30 seconds)...
timeout /t 30 /nobreak >nul

echo.
echo ===============================================
echo STEP 2: Deleting IAM Resources
echo ===============================================
echo.

echo Detaching policy from IAM role...
aws iam detach-role-policy --role-name %IAM_ROLE_NAME% --policy-arn arn:aws:iam::%AWS_ACCOUNT_ID%:policy/%IAM_POLICY_NAME% 2>nul
if %errorlevel% equ 0 (
    echo [OK] Policy detached from role
) else (
    echo [SKIP] Policy not attached or role not found
)

echo.
echo Deleting IAM role...
aws iam delete-role --role-name %IAM_ROLE_NAME% 2>nul
if %errorlevel% equ 0 (
    echo [OK] IAM role deleted
) else (
    echo [SKIP] Role not found or already deleted
)

echo.
echo Deleting IAM policy...
aws iam delete-policy --policy-arn arn:aws:iam::%AWS_ACCOUNT_ID%:policy/%IAM_POLICY_NAME% 2>nul
if %errorlevel% equ 0 (
    echo [OK] IAM policy deleted
) else (
    echo [SKIP] Policy not found or already deleted
)

echo.
echo ===============================================
echo STEP 3: Deleting ECR Repository
echo ===============================================
echo.

echo Deleting ECR repository and all images...
aws ecr delete-repository --repository-name %ECR_REPOSITORY_NAME% --force --region %AWS_REGION% 2>nul
if %errorlevel% equ 0 (
    echo [OK] ECR repository deleted
) else (
    echo [SKIP] Repository not found or already deleted
)

echo.
echo ===============================================
echo STEP 4: Deleting EKS Cluster
echo ===============================================
echo.
echo This will take 10-15 minutes...
echo.

set /p DELETE_CLUSTER="Do you want to delete the EKS cluster? (type YES to confirm): "
if not "%DELETE_CLUSTER%"=="YES" (
    echo Skipping cluster deletion.
    goto :skip_cluster
)

echo.
echo Deleting EKS cluster (this takes 10-15 minutes)...
%HELM_PATH% delete opentelemetry-collector -n %K8S_NAMESPACE% 2>nul
kubectl delete namespace %K8S_NAMESPACE% 2>nul
eksctl delete cluster --name %EKS_CLUSTER_NAME% --region %AWS_REGION% --wait
if %errorlevel% equ 0 (
    echo [OK] EKS cluster deleted successfully
) else (
    echo [WARN] Cluster deletion may have failed or cluster doesn't exist
    echo       You can manually delete it from AWS Console if needed
)

:skip_cluster

echo.
echo ===============================================
echo STEP 5: Removing VPC Subnet Tags (Optional)
echo ===============================================
echo.

set /p REMOVE_TAGS="Remove ELB tags from VPC subnets? (type YES to confirm): "
if not "%REMOVE_TAGS%"=="YES" (
    echo Skipping subnet tag removal.
    goto :cleanup_complete
)

echo.
echo Removing ELB tags from subnets...
echo NOTE: Update this script with your actual subnet IDs
REM for %%s in (subnet-xxx subnet-yyy subnet-zzz) do (
REM     aws ec2 delete-tags --resources %%s --tags Key=kubernetes.io/role/elb --region %AWS_REGION% 2>nul
REM     if !errorlevel! equ 0 (
REM         echo [OK] Removed tags from %%s
REM     ) else (
REM         echo [SKIP] Tags not found on %%s
REM     )
REM )

:cleanup_complete

echo.
echo ===============================================
echo CLEANUP SUMMARY
echo ===============================================
echo.
echo Deleted Resources:
echo [✓] Sample application and service
echo [✓] OpenTelemetry Collector
echo [✓] IAM role: %IAM_ROLE_NAME%
echo [✓] IAM policy: %IAM_POLICY_NAME%
echo [✓] ECR repository: %ECR_REPOSITORY_NAME%

if "%DELETE_CLUSTER%"=="YES" (
    echo [✓] EKS cluster: %EKS_CLUSTER_NAME%
) else (
    echo [SKIPPED] EKS cluster: %EKS_CLUSTER_NAME%
)

echo.
echo Remaining resources to check manually:
echo - CloudWatch Log Groups (if any): /aws/eks/%EKS_CLUSTER_NAME%/
echo - CloudWatch Metrics: OpenTelemetry/App namespace
echo - X-Ray traces and service map data
echo - VPC and subnets (if cluster was deleted by eksctl)
echo.
echo To view any remaining costs:
echo aws ce get-cost-and-usage --time-period Start=2025-11-01,End=2025-12-01 --granularity DAILY --metrics BlendedCost
echo.
echo ===============================================
echo CLEANUP COMPLETE
echo ===============================================
echo.
pause
