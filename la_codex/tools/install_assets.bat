@echo off
REM Los Animales RP asset installation script for Windows.
REM Requires curl, jq and unzip in PATH.

set SCRIPT_DIR=%~dp0
set CODEX_DIR=%SCRIPT_DIR%\..
set MANIFEST_FILE=%CODEX_DIR%\peds\manifest.json

if not exist "%MANIFEST_FILE%" (
    echo Manifest file not found: %MANIFEST_FILE%
    exit /b 1
)

for /f "usebackq delims=" %%i in ('jq -c ".assets[]" "%MANIFEST_FILE%"') do (
    set "row=%%i"
    for /f "delims=" %%j in ('echo %%row%% ^| jq -r ".name"') do set "name=%%j"
    for /f "delims=" %%j in ('echo %%row%% ^| jq -r ".url"') do set "url=%%j"
    echo Downloading %name% from %url% ...
    set "tmpfile=%TEMP%\%name%_asset.zip"
    curl -L "%url%" -o "%tmpfile%"
    mkdir "%CODEX_DIR%\peds\assets\%name%"
    powershell -Command "Expand-Archive -Path '%tmpfile%' -DestinationPath '%CODEX_DIR%\peds\assets\%name%' -Force" >nul
    del "%tmpfile%"
    echo %name% installed.
)

echo All assets installed.