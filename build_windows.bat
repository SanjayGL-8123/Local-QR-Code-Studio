@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ==============================================
echo       Local QR Code Studio - Windows Build
echo ==============================================
echo.

:: Detect Python executable (prefer py launcher, then python)
set "PYCMD="
where py >nul 2>&1
if %errorlevel%==0 (
    set "PYCMD=py"
) else (
    where python >nul 2>&1
    if %errorlevel%==0 (
        set "PYCMD=python"
    )
)

if "%PYCMD%"=="" (
    echo [ERROR] Python was not found in PATH!
    echo Please install Python 3.10 or newer from https://www.python.org/downloads/
    echo and ensure "Add Python to PATH" is ticked during setup.
    echo.
    pause
    exit /b 1
)

echo [OK] Using Python: %PYCMD%
echo.
echo Installing/upgrading required packages...
%PYCMD% -m pip install --upgrade pip
if errorlevel 1 goto failed

%PYCMD% -m pip install -r requirements.txt
if errorlevel 1 goto failed

echo.
echo Building single-file Windows EXE with PyInstaller...
%PYCMD% -m PyInstaller --noconfirm --clean --onefile --windowed --name LocalQRStudio --add-data "templates;templates" app.py
if errorlevel 1 (
    :: Fallback without --windowed in case console is preferred for logging
    %PYCMD% -m PyInstaller --noconfirm --clean --onefile --name LocalQRStudio --add-data "templates;templates" app.py
)
if errorlevel 1 goto failed

:: Unblock and set proper integrity on the generated executable
powershell -NoProfile -Command "Unblock-File -Path '%CD%\dist\LocalQRStudio.exe' -ErrorAction SilentlyContinue; icacls '%CD%\dist\LocalQRStudio.exe' /setintegritylevel (OI)(CI)M /Q >$null 2>&1"

echo.
echo ==============================================
echo Build complete! Your EXE is ready:
echo %CD%\dist\LocalQRStudio.exe
echo ==============================================
echo.
pause
exit /b 0

:failed
echo.
echo [ERROR] Build failed. Review the messages above.
echo.
pause
exit /b 1



