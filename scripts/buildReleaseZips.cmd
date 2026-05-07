@echo off

powershell -ExecutionPolicy Bypass -File .\build.ps1 -Config Release

echo.

powershell -ExecutionPolicy Bypass -File .\compressReleaseZips.ps1

pause