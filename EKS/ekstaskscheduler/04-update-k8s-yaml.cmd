@echo off
REM Update k8s-cronjob.yaml with actual ECR repository URL

if not exist config.txt (
    echo ERROR: config.txt not found. Please run 01-setup-ecr.cmd first.
    pause
    exit /b 1
)

for /f "tokens=1,2 delims==" %%a in (config.txt) do (
    if "%%a"=="ECR_REPO" set ECR_REPO=%%b
)

echo ======================================
echo Updating Kubernetes Manifest
echo ======================================
echo ECR Repository: %ECR_REPO%
echo.

REM Create backup
copy k8s-cronjob.yaml k8s-cronjob.yaml.backup >nul
echo ✓ Backup created: k8s-cronjob.yaml.backup
echo.

REM Replace placeholder with actual ECR repo
powershell -Command "(Get-Content k8s-cronjob.yaml) -replace '<YOUR_ECR_REPO>', '%ECR_REPO%' | Set-Content k8s-cronjob.yaml"

if %ERRORLEVEL% EQU 0 (
    echo ✓ k8s-cronjob.yaml updated successfully
    echo.
    echo Updated images:
    echo   - %ECR_REPO%/ekswebapi:latest
    echo   - %ECR_REPO%/ekstaskscheduler:latest
) else (
    echo ✗ Failed to update k8s-cronjob.yaml
    echo Restoring backup...
    copy k8s-cronjob.yaml.backup k8s-cronjob.yaml >nul
)

echo.
echo Next step: Run 05-deploy-to-eks.cmd to deploy to Kubernetes
echo.
pause
