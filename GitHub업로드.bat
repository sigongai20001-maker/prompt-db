@echo off
setlocal

cd /d "%~dp0"

where git >nul 2>&1
if not "%ERRORLEVEL%"=="0" (
  echo Git was not found. Install Git and try again.
  pause
  exit /b 1
)

git rev-parse --is-inside-work-tree >nul 2>&1
if not "%ERRORLEVEL%"=="0" (
  echo This folder is not a Git repository.
  pause
  exit /b 1
)

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set "STAMP=%%i"

echo Fetching latest GitHub state...
git fetch origin
if not "%ERRORLEVEL%"=="0" goto error

echo Updating local branch...
git pull --rebase origin main
if not "%ERRORLEVEL%"=="0" goto error

echo Staging changes...
git add .
if not "%ERRORLEVEL%"=="0" goto error

git diff --cached --quiet
if "%ERRORLEVEL%"=="0" (
  echo No local changes to commit.
) else (
  echo Creating commit...
  git commit -m "Update prompt DB %STAMP%"
  if not "%ERRORLEVEL%"=="0" goto error
)

echo Pushing to GitHub...
git push
if not "%ERRORLEVEL%"=="0" goto error

echo Done. GitHub has been updated.
pause
exit /b 0

:error
echo.
echo Upload failed. Check the message above.
echo If GitHub asks for login, complete browser login or use a Personal Access Token.
pause
exit /b 1
