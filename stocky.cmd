@echo off
REM Unified Windows launcher for Stocky.
REM Usage: stocky [start|setup|clean|help]
set CMD=%1
if "%CMD%"=="" set CMD=start

if /I "%CMD%"=="help" goto :help
if /I "%CMD%"=="start" goto :start
if /I "%CMD%"=="setup" goto :setup
if /I "%CMD%"=="clean" goto :clean

echo Unknown command: %CMD%
:help
echo Stocky unified launcher

echo   stocky start   - build and run (uses quickstart if present)
echo   stocky setup   - build only
echo   stocky clean   - clean artifacts and local data
exit /b 0

:start
if exist quickstart.sh (
  bash quickstart.sh
) else (
  call run.bat start
)
exit /b %errorlevel%

:setup
call run.bat setup
exit /b %errorlevel%

:clean
call run.bat clean
exit /b %errorlevel%
