@echo off
setlocal
REM 36 bolumluk ana oyunun dokunmatik masaustu onizlemesi; telefon testi degildir.
set "REDMOUNT_TOUCH_CONTROLS=1"
cd /d "%~dp0redmount"
"%~dp0tools\godot-4.7\Godot_v4.7-stable_win64.exe" --path "%~dp0redmount" --resolution 1600x720
if errorlevel 1 pause
endlocal
