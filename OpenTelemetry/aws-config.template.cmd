@echo off
REM AWS Configuration Template
REM Copy this file to aws-config.cmd and fill in your values
REM The aws-config.cmd file will be ignored by git

REM AWS Account Configuration
set AWS_ACCOUNT_ID=YOUR_ACCOUNT_ID_HERE
set AWS_REGION=YOUR_REGION_HERE

REM EKS Cluster Configuration
set EKS_CLUSTER_NAME=YOUR_CLUSTER_NAME_HERE
set EKS_OIDC_ID=YOUR_OIDC_ID_HERE

REM ECR Configuration
set ECR_REPOSITORY_NAME=otel-sample-app

REM IAM Configuration
set IAM_ROLE_NAME=otel-collector-role
set IAM_POLICY_NAME=OtelCollectorPolicy

REM Kubernetes Configuration
set K8S_NAMESPACE=observability
set K8S_SERVICE_ACCOUNT=otel-collector-sa

REM Local Helm Path (customize if needed)
set HELM_PATH=helm
