@echo off
chcp 65001 >nul
rem onefile-vuln-lab launcher (Windows): run.cmd  [port]   default 8095
set PORT=%1
if "%PORT%"=="" set PORT=8095
echo [onefile-vuln-lab] http://127.0.0.1:%PORT%
python "%~dp0app.py" %PORT%
