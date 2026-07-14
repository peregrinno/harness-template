@echo off
REM Start local runtime per project.yaml (bundled_infra | external_infra).
REM Keep dependency services available while developing; agents reuse fixed ports.
setlocal
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-all.ps1"
if errorlevel 1 (
  echo.
  echo [FAIL] start-all failed. Check project.yaml runtime.local_mode and ports.
  exit /b 1
)

echo.
echo [OK] Runtime ready for agents ^(see project.yaml runtime.^)
pause
