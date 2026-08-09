@echo off
chcp 65001 >nul
title MA Warehouse Panel
cd /d "%~dp0"

echo.
echo   =====================================
echo   MA Warehouse - Panel Anbar
echo   =====================================
echo.

:: Try python, then py
python --version >nul 2>&1
if %errorlevel%==0 (
    set PY=python
) else (
    py --version >nul 2>&1
    if %errorlevel%==0 (
        set PY=py
    ) else (
        echo   [!] Python 3 not found.
        echo   Please install Python 3.11+ from https://python.org
        echo   (Check "Add Python to PATH" during install)
        pause
        exit /b 1
    )
)

:: Install deps silently on first run if needed
%PY% -c "import PyQt6, requests, PIL, qrcode" >nul 2>&1
if %errorlevel% neq 0 (
    echo   Installing dependencies - please wait...
    %PY% -m pip install --quiet -r requirements.txt
    echo   Done!
)

echo   Starting...
%PY% app.py
pause
