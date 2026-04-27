@echo off
setlocal EnableDelayedExpansion
title Turno Player - Deploy a Vercel (HTTPS)

set "APPDIR=%~dp0"
if "!APPDIR:~-1!"=="\" set "APPDIR=!APPDIR:~0,-1!"
pushd "!APPDIR!" >nul 2>&1

cls
echo.
echo ===========================================================
echo   TURNO PLAYER - Deploy a Vercel desde GitHub
echo ===========================================================
echo.
echo Carpeta a deployar : !APPDIR!
echo Repo de origen     : https://github.com/ObedGarcia23/mp3
echo.

REM ------- Verificar Node/npm -------
where npm >nul 2>&1
if !errorlevel! NEQ 0 (
    echo *** ERROR: npm no esta instalado.
    echo.
    echo Instala Node.js desde: https://nodejs.org/  (version LTS)
    echo Despues vuelve a ejecutar este archivo.
    echo.
    pause
    goto :end
)

echo [Node detectado]
node -v
npm -v
echo.

REM ------- Verificar/Instalar Vercel CLI -------
where vercel >nul 2>&1
if !errorlevel! NEQ 0 (
    echo Vercel CLI no detectado. Instalando globalmente...
    echo.
    call npm install -g vercel
    if !errorlevel! NEQ 0 (
        echo.
        echo *** ERROR instalando Vercel CLI.
        echo Probá ejecutar este .bat como Administrador, o instala manual:
        echo     npm install -g vercel
        echo.
        pause
        goto :end
    )
    echo.
    echo Vercel CLI instalado OK.
    echo.
)

echo [Vercel CLI detectado]
call vercel --version
echo.

echo ===========================================================
echo   IMPORTANTE: en el primer deploy te va a pedir:
echo   1. Login (abre el navegador para iniciar sesion en Vercel)
echo      RECOMENDADO: login con GitHub para auto-conectar el repo
echo   2. "Set up and deploy" - di Y (yes)
echo   3. "Which scope" - elegi tu cuenta personal
echo   4. "Link to existing project?" - di N (no)
echo   5. "Project name" - dale Enter (acepta el default 'mp3' o
echo      escribi 'turno-player')
echo   6. "In which directory is your code?" - dale Enter
echo   7. "Want to modify settings?" - di N
echo.
echo   Al final te muestra la URL HTTPS publica.
echo ===========================================================
echo.
pause

REM ------- Deploy a produccion -------
call vercel deploy --prod --yes

echo.
echo ===========================================================
echo   Deploy terminado.
echo.
echo   Copia la URL "Production:" que aparece arriba.
echo.
echo   PASOS FINALES:
echo   1. Abre https://vercel.com/dashboard
echo   2. Entra a tu proyecto -^> Settings -^> Git
echo   3. Connect Git Repository -^> ObedGarcia23/mp3
echo      (asi cada git push despliega automatico)
echo.
echo   4. CRITICO: agrega la URL HTTPS en Spotify Dashboard:
echo      https://developer.spotify.com/dashboard
echo      Settings -^> Redirect URIs -^> tu-url-vercel/  (con / final)
echo      Save.
echo ===========================================================
echo.

:end
popd >nul 2>&1
pause
endlocal
