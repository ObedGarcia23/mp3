@echo off
setlocal EnableDelayedExpansion
title Turno Player - Servidor local

REM Forzamos directorio de la app (el directorio donde vive este .bat)
set "APPDIR=%~dp0"
REM Quitar la barra final si existe
if "!APPDIR:~-1!"=="\" set "APPDIR=!APPDIR:~0,-1!"

REM Cambiamos Y ademas pasamos --directory a Python por si acaso
pushd "!APPDIR!" >nul 2>&1

cls
echo.
echo ============================================
echo   TURNO PLAYER - servidor local
echo ============================================
echo.
echo Carpeta servida : !APPDIR!
echo URL             : http://127.0.0.1:8080/
echo.
echo Redirect URI en Spotify Dashboard:
echo     http://127.0.0.1:8080/
echo.
echo (deja esta ventana abierta para que el servidor siga activo)
echo.

REM ------- Verificar que index.html exista en esta carpeta -------
if not exist "!APPDIR!\index.html" (
    echo.
    echo *** ERROR: no encuentro index.html en:
    echo     !APPDIR!
    echo.
    echo Asegurate de que el archivo start.bat este DENTRO de la carpeta "spotify app",
    echo junto a index.html. Si arrastraste solo el start.bat, mueve toda la carpeta.
    echo.
    pause
    goto :end
)

REM ------- Intentar Python -------
where python >nul 2>&1
if !errorlevel!==0 (
    echo [Python detectado] abriendo navegador en 2 segundos...
    timeout /t 2 /nobreak >nul
    start "" "http://127.0.0.1:8080/"
    python -m http.server 8080 --bind 127.0.0.1 --directory "!APPDIR!"
    goto :end
)

REM ------- Intentar py launcher -------
where py >nul 2>&1
if !errorlevel!==0 (
    echo [py launcher detectado] abriendo navegador en 2 segundos...
    timeout /t 2 /nobreak >nul
    start "" "http://127.0.0.1:8080/"
    py -3 -m http.server 8080 --bind 127.0.0.1 --directory "!APPDIR!"
    goto :end
)

REM ------- Fallback: PowerShell -------
echo [Python no detectado] usando PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -File "!APPDIR!\serve.ps1"

:end
popd >nul 2>&1
echo.
echo Servidor detenido.
pause
endlocal
