@echo off
REM Delete ECR repositories

if not exist config.txt (
    echo ERROR: config.txt not found. Please run 01-setup-ecr.cmd first.
    pause
    exit /b 1
)

for /f "tokens=1,2 delims==" %%a in (config.txt) do (
    if "%%a"=="AWS_REGION" set AWS_REGION=%%b
)

echo ======================================
echo DELETE ECR REPOSITORIES WARNING
echo ======================================
echo.
echo This will PERMANENTLY DELETE the following ECR repositories:
echo - ekswebapi
echo - ekstaskscheduler
echo.
echo All images in these repositories will be DELETED!
echo.
echo Are you sure you want to continue? (Y/N)
set /p confirm=

if /i not "%confirm%"=="Y" (
    echo.
    echo Deletion cancelled.
    pause
    exit /b 0
)

echo.
echo ======================================
echo Deleting ECR Repositories
echo ======================================
echo.

echo Deleting ekswebapi repository...
aws ecr delete-repository --repository-name ekswebapi --region %AWS_REGION% --force
if %ERRORLEVEL% EQU 0 (
    echo ✓ ekswebapi repository deleted
) else (
    echo ✗ Failed to delete ekswebapi repository
)

echo.
echo Deleting ekstaskscheduler repository...
aws ecr delete-repository --repository-name ekstaskscheduler --region %AWS_REGION% --force
if %ERRORLEVEL% EQU 0 (
    echo ✓ ekstaskscheduler repository deleted
) else (
    echo ✗ Failed to delete ekstaskscheduler repository
)

echo.
echo ======================================
echo Cleanup Complete
echo ======================================
echo.
pause
