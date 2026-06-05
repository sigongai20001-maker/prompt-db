@echo off
setlocal

cd /d "%~dp0"
set "APP_URL=http://127.0.0.1:8080/prompt-db.html"

netstat -ano | findstr /R /C:":8080 .*LISTENING" >nul 2>&1
if "%ERRORLEVEL%"=="0" (
  echo Port 8080 is already in use. Opening the app only.
  start "" "%APP_URL%"
  echo Browser opened. You may close this window.
  pause
  exit /b 0
)

where python >nul 2>&1
if "%ERRORLEVEL%"=="0" (
  start "" "%APP_URL%"
  echo Starting local server: %APP_URL%
  echo Keep this window open while using Prompt DB.
  python -m http.server 8080 --bind 127.0.0.1
  exit /b %ERRORLEVEL%
)

where py >nul 2>&1
if "%ERRORLEVEL%"=="0" (
  start "" "%APP_URL%"
  echo Starting local server: %APP_URL%
  echo Keep this window open while using Prompt DB.
  py -m http.server 8080 --bind 127.0.0.1
  exit /b %ERRORLEVEL%
)

echo Python was not found.
echo Install Python or add it to PATH, then run this file again.
echo https://www.python.org/downloads/
pause
exit /b 1
