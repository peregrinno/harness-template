@echo off
REM Start all shared infrastructure for harness agents.
REM Keep this window/process running while developing.
setlocal
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-all.ps1"
if errorlevel 1 (
  echo.
  echo [FAIL] Infra failed to start. See messages above.
  exit /b 1
)

echo.
echo [OK] Infra is up. Leave this session alone; agents will use fixed ports from project.yaml.
pause
