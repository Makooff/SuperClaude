@echo off
PowerShell -ExecutionPolicy Bypass -NoProfile -File "%~dp0SuperClaude-Installer.ps1"
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERREUR: L'installeur a rencontre une erreur.
    echo Assure-toi que Claude Code est installe: https://claude.ai/code
    pause
)
