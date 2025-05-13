@echo off
setlocal EnableDelayedExpansion

REM ─── Determine project root (where this .bat lives) ───────────────────
set "root=%~dp0"
if "%root:~-1%"=="\" set "root=%root:~0,-1%"

REM ─── Output file at project root ────────────────────────────────────
set "out=%root%\paths_bfs.csv"

REM ─── Temporary queue files ──────────────────────────────────────────
set "curr=%TEMP%\bfs_curr.tmp"
set "next=%TEMP%\bfs_next.tmp"

REM ─── Cleanup from previous run ───────────────────────────────────────
del "%curr%" 2>nul
del "%next%" 2>nul
del "%out%" 2>nul

echo Generating breadth-first list (files first, then folders) for "%root%" (excluding .git)...

REM ─── LEVEL 0: root folder ───────────────────────────────────────────
REM files in root (suppress "File Not Found")
for /f "delims=" %%F in ('dir "%root%" /b /a-d 2^>nul ^| sort') do (
    echo %%F>>"%out%"
)
REM dirs in root (exclude .git folder)
for /f "delims=" %%D in ('dir "%root%" /b /ad 2^>nul ^| findstr /I /V ".git" ^| sort') do (
    echo %%D\>>"%out%"
    echo %%D>>"%curr%"
)

REM ─── BFS LEVELS: process each queued folder ─────────────────────────
:LOOP
if not exist "%curr%" goto DONE

del "%next%" 2>nul

for /f "usebackq delims=" %%R in ("%curr%") do (
    set "rel=%%R"
    REM files in this folder
    for /f "delims=" %%F in ('dir "%root%\!rel!" /b /a-d 2^>nul ^| sort') do (
        echo !rel!\%%F>>"%out%"
    )
    REM dirs in this folder (exclude .git subfolders)
    for /f "delims=" %%D in ('dir "%root%\!rel!" /b /ad 2^>nul ^| findstr /I /V ".git" ^| sort') do (
        echo !rel!\%%D\>>"%out%"
        echo !rel!\%%D>>"%next%"
    )
)

del "%curr%" 2>nul
move "%next%" "%curr%" >nul 2>nul
goto LOOP

:DONE
echo Done! All paths written to "%out%".
pause
endlocal