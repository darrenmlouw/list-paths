@echo off
setlocal EnableDelayedExpansion

REM ─── Determine project root (where this .bat lives) ─────────────────
set "root=%~dp0"
if "%root:~-1%"=="\" set "root=%root:~0,-1%"

REM ─── Output CSV at root ─────────────────────────────────────────────
set "out=%root%\paths_fast.csv"

echo Generating list of paths for "%root%" (excluding .git)...

(
  REM ─── Directories (exclude .git folder & contents) ────────────────
  for /f "delims=" %%D in ('
    dir "%root%" /s /b /ad ^
    ^| findstr /i /v "\\.git\\" ^
    ^| findstr /i /v "\\.git$" ^
    ^| sort
  ') do (
    set "full=%%D"
    setlocal enabledelayedexpansion
    set "rel=!full:%root%\=!"
    echo !rel!\
    endlocal
  )

  REM ─── Files (exclude anything under .git) ────────────────────────
  for /f "delims=" %%F in ('
    dir "%root%" /s /b /a-d ^
    ^| findstr /i /v "\\.git\\" ^
    ^| sort
  ') do (
    set "full=%%F"
    setlocal enabledelayedexpansion
    set "rel=!full:%root%\=!"
    echo !rel!
    endlocal
  )

) > "%out%"

echo Done! Wrote all paths to "%out%".
pause
endlocal 