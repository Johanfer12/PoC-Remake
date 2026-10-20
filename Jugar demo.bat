@echo off
rem Lanza el demo del remake de Power of Chaos (Godot) desde esta carpeta.
setlocal
rem ANGLE conserva Compatibility/GLES3 y evita las caidas de igxelpicd64.dll al cerrar.
rem Para comparar con OpenGL nativo: set POC_RENDERING_DRIVER=opengl3
if not defined POC_RENDERING_DRIVER set "POC_RENDERING_DRIVER=opengl3_angle"
set "ROOT=%~dp0"
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Links\godot.exe"
if defined POC_GODOT_EXE set "GODOT=%POC_GODOT_EXE%"
if not exist "%GODOT%" (
    where godot >nul 2>&1 && set "GODOT=godot"
)
if not exist "%GODOT%" if not "%GODOT%"=="godot" (
    echo No se encontro Godot. Instalalo con: winget install GodotEngine.GodotEngine
    pause
    exit /b 1
)
start "" "%GODOT%" --rendering-driver "%POC_RENDERING_DRIVER%" --path "%ROOT%game" %*
