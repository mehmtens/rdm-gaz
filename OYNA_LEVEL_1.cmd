@echo off
setlocal
cd /d "%~dp0redmount"
"%~dp0tools\godot-4.7\Godot_v4.7-stable_win64.exe" --path "%~dp0redmount" "res://scenes/Main.tscn"
if errorlevel 1 pause
endlocal
