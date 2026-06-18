@echo off
title Avvio SpotIt Catania 🌋
color 0B
echo =======================================================
echo              AVVIO DI SPOTIT CATANIA 🌋
echo =======================================================
echo.
echo  [1] Avvia l'applicazione Flutter (Mobile UI su Chrome)
echo  [2] Apri il Portale Web e Simulatore (Leggero e Istantaneo)
echo.
echo =======================================================
set /p scelta="Digita il numero dell'opzione (1 o 2) e premi Invio: "

if "%scelta%"=="1" (
    echo.
    echo Avvio dell'applicazione Flutter in corso...
    cd /d C:\Users\hp\Desktop\spotit
    C:\src\flutter\bin\flutter.bat run -d chrome
) else (
    echo.
    echo Apertura del Portale Web in corso...
    start "" "C:\Users\hp\Desktop\spotit\spotit_web\index.html"
)
pause
