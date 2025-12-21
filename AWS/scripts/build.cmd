@echo off
REM Build the .NET application locally
echo Building .NET application...
dotnet build HelloWorldApp\HelloWorldApp.csproj -c Release

if %ERRORLEVEL% EQU 0 (
    echo Build successful!
) else (
    echo Build failed!
    exit /b 1
)
