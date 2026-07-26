@echo off
REM X3D Setup Guide Launcher
REM This batch file launches the enhanced GUI wrapper for the X3D Setup Guide

echo.
echo ===============================================
echo    X3D SETUP GUIDE - ENHANCED INTERFACE LAUNCHER
echo ===============================================
echo.

REM Check if PowerShell is available
powershell.exe -Command "Write-Host 'PowerShell is available' -ForegroundColor Green"

REM Set execution policy and run the enhanced wrapper
powershell.exe -ExecutionPolicy Bypass -File "%~dp0X3D-Setup-Guide-Enhanced-GUI.ps1"

echo.
echo ===============================================
echo    Launch completed. Press any key to exit...
echo ===============================================
echo.
pause