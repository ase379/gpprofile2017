# Build gpprof for Win32 and Win64 and deploy to BIN/ and bin64/
#
# Requirements:
#   - Delphi (RAD Studio) installed with MSBuild integration
#   - Run from the 'scripts' directory or set $PSScriptRoot correctly
#
# Usage:
#   .\build.ps1
#   .\build.ps1 -Config Release
#   .\build.ps1 -Config Debug

param(
    [string]$Config = "Release"
)

$ErrorActionPreference = "Stop"

$repoRoot   = Resolve-Path "$PSScriptRoot\.."
$projectFile = Join-Path $repoRoot "source\gpprof.dproj"
$binDir     = Join-Path $repoRoot "BIN"
$bin64Dir   = Join-Path $repoRoot "bin64"

if (-not (Test-Path $projectFile)) {
    Write-Error "Project file not found: $projectFile"
    exit 1
}

###########################################################################
# SET BDS TO BE ABLE TO COMPILE DELPHI WITH MSBUILD
###########################################################################

$DelphiInstallLocation = "${Env:ProgramFiles(x86)}\Embarcadero\Studio\37.0"
if (!(Test-Path $DelphiInstallLocation)) {
    Write-Error "Couldn't find Delphi Install..."
    exit 1
} else {
    Write-Host "Found Delphi Install at $DelphiInstallLocation"
    $env:BDS = $DelphiInstallLocation
}

# Find MSBuild (RAD Studio relies on Visual Studio's MSBuild, not its own)
$msbuild = $null
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    $vsInstall = & $vswhere -latest -property installationPath 2>$null
    if ($vsInstall) {
        $candidate = Join-Path $vsInstall "MSBuild\Current\Bin\MSBuild.exe"
        if (Test-Path $candidate) { $msbuild = $candidate }
    }
}
if (-not $msbuild) {
    $found = Get-Command "MSBuild.exe" -ErrorAction SilentlyContinue
    if ($found) { $msbuild = $found.Source }
}
if (-not $msbuild) {
    Write-Error "MSBuild.exe not found. Please ensure Visual Studio or Build Tools are installed."
    exit 1
}

Write-Host "Using MSBuild: $msbuild" -ForegroundColor Cyan
Write-Host "Project: $projectFile" -ForegroundColor Cyan
Write-Host "Config:  $Config" -ForegroundColor Cyan

# Ensure output directories exist
New-Item -Path $binDir   -ItemType Directory -Force | Out-Null
New-Item -Path $bin64Dir -ItemType Directory -Force | Out-Null

# Build Win32
Write-Host ""
Write-Host "Building Win32 ($Config)..." -ForegroundColor Green
& $msbuild $projectFile /t:Build /p:Config=$Config /p:Platform=Win32 /nologo /v:minimal
if ($LASTEXITCODE -ne 0) {
    Write-Error "Win32 build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
Write-Host "Win32 build succeeded. Output: $binDir" -ForegroundColor Green

# Build Win64
Write-Host ""
Write-Host "Building Win64 ($Config)..." -ForegroundColor Green
& $msbuild $projectFile /t:Build /p:Config=$Config /p:Platform=Win64 /nologo /v:minimal
if ($LASTEXITCODE -ne 0) {
    Write-Error "Win64 build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
Write-Host "Win64 build succeeded. Output: $bin64Dir" -ForegroundColor Green

Write-Host ""
Write-Host "Build complete." -ForegroundColor Cyan
