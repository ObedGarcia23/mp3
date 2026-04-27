@echo off
setlocal EnableDelayedExpansion
title Turno Player - Push a GitHub (ObedGarcia23/mp3)

set "APPDIR=%~dp0"
if "!APPDIR:~-1!"=="\" set "APPDIR=!APPDIR:~0,-1!"
pushd "!APPDIR!" >nul 2>&1

set "REPO_URL=https://github.com/ObedGarcia23/mp3.git"
set "BRANCH=main"

cls
echo.
echo ===========================================================
echo   TURNO PLAYER - Push a GitHub
echo ===========================================================
echo.
echo Carpeta : !APPDIR!
echo Repo    : !REPO_URL!
echo Rama    : !BRANCH!
echo.

REM ------- Verificar git -------
where git >nul 2>&1
if !errorlevel! NEQ 0 (
    echo *** ERROR: git no esta instalado.
    echo Instala Git desde: https://git-scm.com/download/win
    echo Despues vuelve a ejecutar este archivo.
    echo.
    pause
    goto :end
)

echo [Git detectado]
git --version
echo.

REM ------- Inicializar repo si hace falta -------
if not exist "!APPDIR!\.git" (
    echo Inicializando repo local...
    git init
    git branch -M !BRANCH!
    echo.
)

REM ------- Configurar user.name y user.email locales si no estan -------
git config user.name >nul 2>&1
if !errorlevel! NEQ 0 (
    git config user.name "ObedGarcia23"
)
git config user.email >nul 2>&1
if !errorlevel! NEQ 0 (
    git config user.email "bardalesdaysi@gmail.com"
)

REM ------- Configurar remote origin -------
git remote get-url origin >nul 2>&1
if !errorlevel! NEQ 0 (
    echo Agregando remote origin -^> !REPO_URL!
    git remote add origin !REPO_URL!
) else (
    echo Actualizando remote origin -^> !REPO_URL!
    git remote set-url origin !REPO_URL!
)
echo.

REM ------- Stage + commit -------
echo Agregando archivos...
git add -A

REM Verificar si hay cambios
git diff --cached --quiet
if !errorlevel! EQU 0 (
    echo.
    echo No hay cambios nuevos para commit.
    echo.
) else (
    echo.
    set /p MSG="Mensaje de commit (Enter para 'update'): "
    if "!MSG!"=="" set "MSG=update"
    git commit -m "!MSG!"
    echo.
)

REM ------- Push -------
echo Empujando a GitHub...
echo.
echo Si te pide credenciales:
echo   - Usuario: ObedGarcia23
echo   - Password: usa un Personal Access Token (NO tu password de GitHub)
echo     Crea uno en: https://github.com/settings/tokens
echo     Permisos minimos: "repo"
echo.

git push -u origin !BRANCH!
if !errorlevel! NEQ 0 (
    echo.
    echo *** Falla en el push. Si dice "non-fast-forward" o "rejected",
    echo *** el repo remoto tiene cambios que no estan aca. Probá:
    echo.
    echo     git pull origin !BRANCH! --allow-unrelated-histories
    echo     git push -u origin !BRANCH!
    echo.
    echo Si pide login y nunca te dio el prompt, instala Git Credential
    echo Manager (viene con Git for Windows mas reciente).
    echo.
)

echo.
echo ===========================================================
echo   Listo. Repo: https://github.com/ObedGarcia23/mp3
echo.
echo   Siguiente paso: doble clic en deploy.bat para conectar
echo   este repo a Vercel y obtener la URL HTTPS publica.
echo ===========================================================
echo.

:end
popd >nul 2>&1
pause
endlocal
