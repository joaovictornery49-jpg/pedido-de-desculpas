@echo off
cd /d "%~dp0"
title Site - link para o celular
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0abrir-hoje.ps1"
echo.
pause
