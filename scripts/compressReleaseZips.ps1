$version = "1.6.0.10"

$scriptDir   = if ($PSScriptRoot) { $PSScriptRoot } else { $PWD.Path }
$repoRoot    = (Resolve-Path (Join-Path $scriptDir "..")).Path
$includeDir  = Join-Path $repoRoot "include"

$buildConfigs = @(
    @{
        Name      = "32-bit"
        SrcBin    = Join-Path $repoRoot "bin"
        TargetDir = Join-Path $repoRoot "gpprof_2017_v$version"
    },
    @{
        Name      = "64-bit"
        SrcBin    = Join-Path $repoRoot "bin64"
        TargetDir = Join-Path $repoRoot "gpprof_2017x64_v$version"
    }
)

foreach ($config in $buildConfigs) {
    Write-Host "Creating $($config.Name) release zip" -ForegroundColor Cyan
    
    $zipFile = $config.TargetDir + ".zip"
    
    # Clean up existing temporary folders and old archives
    if (Test-Path $config.TargetDir) {
        Write-Host "Removing existing temporary folder: $($config.TargetDir)" -ForegroundColor DarkGray
        Remove-Item $config.TargetDir -Recurse -Force
    }
    if (Test-Path $zipFile) {
        Write-Host "Removing old archive: $zipFile" -ForegroundColor DarkGray
        Remove-Item $zipFile -Force
    }

    # Create directory structure
    Write-Host "Creating folder structure..." -ForegroundColor Green
    $targetInclude = Join-Path $config.TargetDir "include"
    New-Item -Path $targetInclude -ItemType Directory -Force | Out-Null

    # Copy binary artifacts (.exe, .chm, .eul)
    Write-Host "Copying binaries from $($config.SrcBin)..." -ForegroundColor Gray
    Copy-Item -Path "$($config.SrcBin)\*" -Include "*.exe", "*.chm", "*.eul" -Destination $config.TargetDir

    # Copy include files (.pas, .inc)
    Write-Host "Copying include files..." -ForegroundColor Gray
    Copy-Item -Path "$includeDir\*" -Include "*.pas", "*.inc" -Destination $targetInclude

    # Create new archive
    Write-Host "Creating archive: $zipFile" -ForegroundColor Yellow
    Compress-Archive -LiteralPath $config.TargetDir -DestinationPath $zipFile

    # Final cleanup of the temporary folder
    Write-Host "Cleaning up temporary folder..." -ForegroundColor DarkGray
    Remove-Item $config.TargetDir -Recurse -Force
}

Write-Host "Done" -ForegroundColor Green

