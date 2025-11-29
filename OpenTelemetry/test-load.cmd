@echo off
echo Generating load on the sample application...
echo.

set URL=%1
if "%URL%"=="" set URL=http://localhost:5000

echo Target: %URL%
echo Press Ctrl+C to stop
echo.

:loop
for /L %%i in (1,1,10) do (
    curl -s "%URL%/" > nul
    echo [%%i] GET / - OK
)

for /L %%i in (1,1,5) do (
    curl -s "%URL%/api/users/%%i" > nul
    echo [%%i] GET /api/users/%%i - OK
)

curl -s "%URL%/api/slow" > nul
echo GET /api/slow - OK

timeout /t 2 /nobreak > nul
goto loop
