# Build gpprof for Win32 and Win64
#
# Requirements:
#   - Delphi RAD Studio (paid/professional edition) installed
#     NOTE: The Community Edition does NOT support command-line compilation.
#           You need a Professional, Enterprise, or Architect edition.
#   - Windows PowerShell 5.1 or later
#
# Usage (run from the repo root or any directory):
#   .\scripts\build.ps1
#   .\scripts\build.ps1 -Config Release
#   .\scripts\build.ps1 -Config Debug
#   .\scripts\build.ps1 -BDS 23

param(
    [string]$Config  = "Release",
    
    # Specific RAD Studio version (e.g., "21" or "21.0")
    [string]$BDS     = ""
)

$ErrorActionPreference = "Stop"

$scriptDir   = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
$repoRoot    = (Resolve-Path (Join-Path $scriptDir "..")).Path
$projectFile = Join-Path $repoRoot "source\gpprof.dproj"
$binDir      = Join-Path $repoRoot "bin"
$bin64Dir    = Join-Path $repoRoot "bin64"

if (-not (Test-Path $projectFile)) {
    Write-Error "Project file not found: $projectFile"
    exit 1
}

# Normalize version string (e.g., "21" -> "21.0")
if ($BDS -and ($BDS -notmatch '\.')) {
    $BDS = "$BDS.0"
}

###########################################################################
# LOCATE RAD STUDIO AND LOAD ITS BUILD ENVIRONMENT VIA rsvars.bat
###########################################################################

# Detect RAD Studio version
$DelphiInstallLocation = $null

$registryRoots = @(
    'HKLM:\SOFTWARE\WOW6432Node\Embarcadero\BDS',
    'HKLM:\SOFTWARE\Embarcadero\BDS',
    'HKCU:\Software\Embarcadero\BDS'
)

foreach ($regRoot in $registryRoots) {
    if (Test-Path $regRoot) {
        if ($BDS) {
            # Search for specific version
            $verPath = Join-Path $regRoot $BDS
            if (Test-Path $verPath) {
                $rootDir = (Get-ItemProperty -Path $verPath -Name 'RootDir' -ErrorAction SilentlyContinue).RootDir
                if ($rootDir -and (Test-Path $rootDir)) {
                    $DelphiInstallLocation = $rootDir.TrimEnd('\')
                    break
                }
            }
        } else {
            # Auto-detect the latest version
            $versions = Get-ChildItem $regRoot -ErrorAction SilentlyContinue |
                Where-Object { $_.PSChildName -match '^\d+\.\d+$' } |
                Sort-Object { [double]$_.PSChildName } -Descending

            foreach ($ver in $versions) {
                $rootDir = (Get-ItemProperty -Path $ver.PSPath -Name 'RootDir' -ErrorAction SilentlyContinue).RootDir
                if ($rootDir -and (Test-Path $rootDir)) {
                    $DelphiInstallLocation = $rootDir.TrimEnd('\')
                    break
                }
            }
        }
    }
    if ($DelphiInstallLocation) { break }
}

if (-not $DelphiInstallLocation) {
    $errorMsg = if ($BDS) { "Couldn't find RAD Studio version $BDS" } else { "Couldn't find any RAD Studio installation" }
    Write-Error $errorMsg
    exit 1
} else {
    Write-Host "Found RAD Studio at: $DelphiInstallLocation"
    $env:BDS = $DelphiInstallLocation
}

# Load environment variables via rsvars.bat
$rsVars = Join-Path $DelphiInstallLocation "bin\rsvars.bat"
if (-not (Test-Path $rsVars)) {
    Write-Error "rsvars.bat not found at: $rsVars"
    exit 1
}

Write-Host "Loading RAD Studio environment from: $rsVars"
cmd /c "`"$rsVars`" && set" | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], 'Process')
    }
}

$msbuildCmd = Get-Command "MSBuild.exe" -ErrorAction SilentlyContinue
$msbuild = if ($msbuildCmd) { $msbuildCmd.Source } else { $null }
if (-not $msbuild) {
    Write-Error "MSBuild.exe not found on PATH after loading rsvars.bat."
    exit 1
}

Write-Host "Using MSBuild : $msbuild" -ForegroundColor Cyan
Write-Host "Project       : $projectFile" -ForegroundColor Cyan
Write-Host "Config        : $Config" -ForegroundColor Cyan
Write-Host ""
Write-Warning "NOTE: Command-line compilation requires a paid RAD Studio edition (Professional/Enterprise/Architect). The Community Edition is NOT supported and will fail with 'This version does not support command line compiling'."

# Ensure output directories exist before MSBuild runs
New-Item -Path $binDir   -ItemType Directory -Force | Out-Null
New-Item -Path $bin64Dir -ItemType Directory -Force | Out-Null

###########################################################################
# BUILD
###########################################################################

$platforms = @(
    @{ Name = "Win32"; OutDir = $binDir }
    @{ Name = "Win64"; OutDir = $bin64Dir }
)

foreach ($p in $platforms) {
    Write-Host ""
    Write-Host "Building $($p.Name) ($Config)..." -ForegroundColor Green
    
    & $msbuild $projectFile /t:Build /p:Config=$Config /p:Platform=$($p.Name) /nologo /v:minimal
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "$($p.Name) build failed with exit code $LASTEXITCODE"
        exit $LASTEXITCODE
    }
    
    Write-Host "$($p.Name) build succeeded. Output: $($p.OutDir)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Build complete." -ForegroundColor Cyan
