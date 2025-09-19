@echo off
set COMMAND=%1
if "%COMMAND%"=="" set COMMAND=start
set JAR=stocky-api\target\stocky-api.jar

:ensure_java
java -version >NUL 2>&1 || (
  echo [ERROR] Java (JDK 17+) not found in PATH.
  exit /b 1
)

if /I "%COMMAND%"=="setup" goto setup
if /I "%COMMAND%"=="start" goto start
if /I "%COMMAND%"=="clean" goto clean
if /I "%COMMAND%"=="help" goto help

echo Unknown command: %COMMAND%
goto help

:setup
echo [INFO] Building project (frontend + backend)...
cd stocky-api
call mvnw -q -DskipTests package
cd ..
echo [INFO] Build complete: %JAR%
goto :eof

:start
if not exist %JAR% (
  echo [INFO] JAR not found. Running setup first...
  call %0 setup
)
if not exist stocky-api\data\h2 mkdir stocky-api\data\h2
java -jar %JAR% --spring.profiles.active=offline
goto :eof

:clean
echo [INFO] Cleaning build artifacts & local data
cd stocky-api
call mvnw -q clean
cd ..
if exist stocky-api\data rmdir /s /q stocky-api\data

echo [INFO] Clean complete
goto :eof

:help
echo Usage: run.bat ^<command^>
echo Commands:
echo   setup   Build everything (downloads dependencies) without starting
echo   start   Build if needed then run the self-contained server (default)
echo   clean   Remove build outputs and local H2 data
echo   help    Show this help
