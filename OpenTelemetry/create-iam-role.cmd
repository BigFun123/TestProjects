@echo off

REM Load configuration
if not exist aws-config.cmd (
    echo ERROR: aws-config.cmd not found!
    echo Please copy aws-config.template.cmd to aws-config.cmd and configure it.
    exit /b 1
)
call aws-config.cmd

echo Creating IAM role for OpenTelemetry Collector with IRSA...
echo.

set CLUSTER_NAME=%EKS_CLUSTER_NAME%
set REGION=%AWS_REGION%
set ACCOUNT_ID=%AWS_ACCOUNT_ID%
set NAMESPACE=%K8S_NAMESPACE%
set SERVICE_ACCOUNT=%K8S_SERVICE_ACCOUNT%
set POLICY_ARN=arn:aws:iam::%ACCOUNT_ID%:policy/%IAM_POLICY_NAME%

echo Getting OIDC provider for cluster...
for /f "tokens=*" %%i in ('aws eks describe-cluster --name %CLUSTER_NAME% --region %REGION% --query "cluster.identity.oidc.issuer" --output text') do set OIDC_URL=%%i
set OIDC_ID=%OIDC_URL:~8%

echo OIDC Provider: %OIDC_ID%
echo.

echo Creating IAM role trust policy...
(
echo {
echo   "Version": "2012-10-17",
echo   "Statement": [
echo     {
echo       "Effect": "Allow",
echo       "Principal": {
echo         "Federated": "arn:aws:iam::%ACCOUNT_ID%:oidc-provider/%OIDC_ID%"
echo       },
echo       "Action": "sts:AssumeRoleWithWebIdentity",
echo       "Condition": {
echo         "StringEquals": {
echo           "%OIDC_ID%:sub": "system:serviceaccount:%NAMESPACE%:%SERVICE_ACCOUNT%",
echo           "%OIDC_ID%:aud": "sts.amazonaws.com"
echo         }
echo       }
echo     }
echo   ]
echo }
) > trust-policy.json

echo Creating IAM role...
aws iam create-role ^
  --role-name %IAM_ROLE_NAME% ^
  --assume-role-policy-document file://trust-policy.json ^
  --description "IAM role for OpenTelemetry Collector with IRSA"

echo.
echo Attaching policy to role...
aws iam attach-role-policy ^
  --role-name %IAM_ROLE_NAME% ^
  --policy-arn %POLICY_ARN%

echo.
echo IAM role created: arn:aws:iam::%ACCOUNT_ID%:role/%IAM_ROLE_NAME%
echo.
echo Next steps:
echo 1. Create the namespace: kubectl create namespace %NAMESPACE%
echo 2. Update kubernetes manifests with the role ARN
echo 3. Deploy OpenTelemetry Collector
echo.

del trust-policy.json
