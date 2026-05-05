# Build gpprof for Win32 and Win64 and deploy to bin/
#
# Requirements:
#   - Delphi RAD Studio (paid/professional edition) installed at
#     %ProgramFiles(x86)%\Embarcadero\Studio\<version>
#     (auto-detects the latest installed version from 99.0 down to 21.0)
#     NOTE: The Community Edition does NOT support command-line compilation.
#           You need a Professional, Enterprise, or Architect edition.
#   - Windows PowerShell 5.1 or later
#
# Usage (run from the repo root or any directory):
#   .\scripts\build.ps1
#   .\scripts\build.ps1 -Config Release
#   .\scripts\build.ps1 -Config Debug

param(
    [string]$Config = "Release"
)

$ErrorActionPreference = "Stop"

$repoRoot    = Resolve-Path "$PSScriptRoot\.."
$projectFile = Join-Path $repoRoot "source\GpProf.UI\gpprof.dproj"
$dllProject  = Join-Path $repoRoot "source\gpprof.dll\GpProfDll.dproj"
$binDir      = Join-Path $repoRoot "bin"

if (-not (Test-Path $projectFile)) {
    Write-Error "Project file not found: $projectFile"
    exit 1
}

if (-not (Test-Path $dllProject)) {
    Write-Error "DLL project file not found: $dllProject"
    exit 1
}

###########################################################################
# SET BDS AND LOAD FULL DELPHI BUILD ENVIRONMENT VIA rsvars.bat
###########################################################################

# Auto-detect the latest installed RAD Studio version (99.0 down to 21.0)
$DelphiInstallLocation = $null
$studioBase = "${Env:ProgramFiles(x86)}\Embarcadero\Studio"
for ($v = 99; $v -ge 21; $v--) {
    $candidate = "$studioBase\$v.0"
    if (Test-Path $candidate) {
        $DelphiInstallLocation = $candidate
        break
    }
}

if (-not $DelphiInstallLocation) {
    Write-Error "Couldn't find Delphi Install in $studioBase (searched 99.0 down to 21.0)"
    exit 1
} else {
    Write-Host "Found Delphi Install at $DelphiInstallLocation"
    $env:BDS = $DelphiInstallLocation
}

# rsvars.bat sets BDS, BDSPLATFORMSDKSDIR, FrameworkDir, FrameworkVersion,
# MSBUILD_VERSION and adds the correct MSBuild.exe to PATH.
$rsVars = Join-Path $DelphiInstallLocation "bin\rsvars.bat"
if (-not (Test-Path $rsVars)) {
    Write-Error "rsvars.bat not found at: $rsVars"
    exit 1
}
Write-Host "Loading Delphi environment from $rsVars"
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

Write-Host "Using MSBuild: $msbuild" -ForegroundColor Cyan
Write-Host "UI project:  $projectFile" -ForegroundColor Cyan
Write-Host "DLL project: $dllProject" -ForegroundColor Cyan
Write-Host "Config:      $Config" -ForegroundColor Cyan
Write-Host ""
Write-Warning "NOTE: Command-line compilation requires a paid RAD Studio edition (Professional/Enterprise/Architect). The Community Edition is NOT supported and will fail with 'This version does not support command line compiling'."

# Ensure output directory exists
New-Item -Path $binDir -ItemType Directory -Force | Out-Null

###########################################################################
# BUILD GpProfDll (shared profiling DLL)
###########################################################################

Write-Host ""
Write-Host "Building GpProfDll Win32 ($Config)..." -ForegroundColor Green
& $msbuild $dllProject /t:Build /p:Config=$Config /p:Platform=Win32 /nologo /v:minimal
if ($LASTEXITCODE -ne 0) {
    Write-Error "GpProfDll Win32 build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
Write-Host "GpProfDll Win32 build succeeded. Output: $binDir" -ForegroundColor Green

Write-Host ""
Write-Host "Building GpProfDll Win64 ($Config)..." -ForegroundColor Green
& $msbuild $dllProject /t:Build /p:Config=$Config /p:Platform=Win64 /nologo /v:minimal
if ($LASTEXITCODE -ne 0) {
    Write-Error "GpProfDll Win64 build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
Write-Host "GpProfDll Win64 build succeeded. Output: $binDir" -ForegroundColor Green

###########################################################################
# BUILD MAIN UI APPLICATION
###########################################################################

# Build Win64
Write-Host ""
Write-Host "Building Win64 ($Config)..." -ForegroundColor Green
& $msbuild $projectFile /t:Build /p:Config=$Config /p:Platform=Win64 /nologo /v:minimal
if ($LASTEXITCODE -ne 0) {
    Write-Error "Win64 build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}
Write-Host "Win64 build succeeded. Output: $binDir" -ForegroundColor Green

Write-Host ""
Write-Host "Build complete." -ForegroundColor Cyan

Andreas Seehusen 
Senior Principal, Software Architecture 
Forterro | Windows & Doors
andreas.seehusen@forterro.com
 
www.forterro.com
 
   

ORGADATA Software-Dienstleistungen AG | Am Nesseufer 14 | 26789 Leer | Germany
Co-Chairs of the Board / Vorstand: Marcus Pannier, Paul Smolinski
Chair of the Supervisory Board / Aufsichtsratsvorsitzender: Dean Anthony Edward Forbes
Registered Office / Sitz der Gesellschaft: Leer
Commercial Register / Handelsregister: HRB 110929 Amtsgericht Aurich 

Informationen zum Umgang mit Ihren personenbezogenen Daten nach den Art. 13 und 14 EU-DSGVO finden Sie unter  https://www.orgadata.com/global/de/data-privacy-statement.html.
Further information according to Art. 13 and 14 GDPR about processing your personal data you can find here:  https://www.orgadata.com/global/en/data-privacy-statement.html. 
