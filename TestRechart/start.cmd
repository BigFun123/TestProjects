@echo off
echo Starting TestRechart Backend...
cd backend
start "TestRechart Backend" cmd /k "dotnet run"
timeout /t 3 /nobreak >nul

echo Starting TestRechart Frontend...
cd ..\frontend
start "TestRechart Frontend" cmd /k "npm run dev"

echo.
echo ========================================
echo TestRechart is starting!
echo ========================================
echo Backend:  http://localhost:5000
echo Frontend: http://localhost:5173
echo ========================================
