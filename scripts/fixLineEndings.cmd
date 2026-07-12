@echo off

for %%d in (source include tests GPComponents) do (
    powershell -ExecutionPolicy Bypass -File .\fixLineEndings.ps1 -Path "..\%%d"
    echo.
)

pause