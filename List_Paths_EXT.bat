@echo off
setlocal EnableDelayedExpansion
REM ────────────────────────────────────────────────────────────────────────────
REM  List_Paths_ByExt.bat  – one path per line, blank line between folders
REM ────────────────────────────────────────────────────────────────────────────

REM —— Root folder (default = this BAT’s folder)
set "root=%~1"
if "%root%"=="" set "root=%~dp0"
if "%root:~-1%"=="\" set "root=%root:~0,-1%"
shift

REM —— Extensions (preserve order; default .ewp .gpj)
set "exts=%*"
if "%exts%"=="" set "exts=.ewp .gpj"

REM —— Output file
set "out=%root%\paths_makefiles.txt"
> "%out%" (

  for %%E in (%exts%) do (
      echo ## Files matching %%E
      set "lastDir="

      for /f "delims=" %%F in ('
        dir "%root%\*%%E" /s /b /a-d 2^>nul ^
        ^| findstr /i /v "\\\.git\\\" ^
        ^| sort
      ') do (
          REM relative directory of this file
          set "absDir=%%~dpF"
          set "relDir=!absDir:%root%\=!"
          if not "!relDir:~-1!"=="\" set "relDir=!relDir!\"

          REM blank line when folder changes (skip before first file)
          if defined lastDir if /i "!relDir!" NEQ "!lastDir!" echo.

          echo !relDir!%%~nxF
          set "lastDir=!relDir!"
      )
      echo.   REM blank line after each extension section
  )
)

echo Done – wrote "%out%"
endlocal
