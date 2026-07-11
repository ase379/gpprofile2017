# This script automates the maintenance and formatting of Delphi project files (.dpr).
#
# In general, it performs two primary tasks:
#
# 1. Path Synchronization: Scans the source directory for all .pas files and updates their relative paths within the .dpr file.
#    This ensures that unit references are automatically fixed if files are moved or reorganized within the project structure.
#
# 2. Uses Clause Sorting: Parses the uses section in the .dpr file, separates system modules from project-specific modules,
#    and alphabetically sorts the project modules based on their relative file paths (the string after the "in" keyword).

param (
    # Resolve the project directory relative to the script location (..\source)
    [string]$ProjectDir = (Join-Path (Split-Path $PSScriptRoot -Parent) "source"),
    [string]$DprFile = "gpprof.dpr"
)

$ProjectDir = (Resolve-Path $ProjectDir).Path

if (-not (Test-Path $ProjectDir)) {
    Write-Warning "Source directory not found: $ProjectDir"
    exit
}

$dprPath = Join-Path $ProjectDir $DprFile

# 1. Scan .pas files (excluding hidden directories starting with . or __)
$pasFiles = Get-ChildItem -Path $ProjectDir -Filter "*.pas" -Recurse | Where-Object { $_.DirectoryName -notmatch "\\\.|\\__" }
$pasMap = @{}

foreach ($file in $pasFiles) {
    # Get the relative path for the Delphi project
    $relPath = $file.FullName.Substring($ProjectDir.Length + 1)

    if ($pasMap.ContainsKey($file.Name) -and $pasMap[$file.Name] -ne $relPath) {
        Write-Warning "Duplicate file name '$($file.Name)': found at '$($pasMap[$file.Name])' and '$relPath'. The latter will be used - verify this is the intended file."
    }
    $pasMap[$file.Name] = $relPath
}

# Function to update paths within the .dpr file
function Update-ProjectPaths([string]$filePath) {
    if (-not (Test-Path $filePath)) { return }
    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

    $newContent = [regex]::Replace($content, "(?i)'([^']*\.pas)'", {
        param($match)
        $oldPath = $match.Groups[1].Value
        $fileName = Split-Path $oldPath -Leaf

        # Update path if the file was found and its location changed
        if ($pasMap.ContainsKey($fileName) -and $pasMap[$fileName] -ne $oldPath) {
            Write-Host "Patching: $oldPath -> $($pasMap[$fileName])"
            return "'$($pasMap[$fileName])'"
        }
        return $match.Value
    })

    if ($content -ne $newContent) {
        [System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)
        Write-Host "Paths updated in $(Split-Path $filePath -Leaf)"
    }
}

# Apply path patching
Update-ProjectPaths $dprPath

# 2. Sort the uses section in the .dpr file
if (Test-Path $dprPath) {
    $dprContent = [System.IO.File]::ReadAllText($dprPath, [System.Text.Encoding]::UTF8)

    $usesMatch = [regex]::Match($dprContent, "(?is)\buses\b(\s*)(.*?);")

    if ($usesMatch.Success) {
        $whitespaceGroup = $usesMatch.Groups[1]
        $contentGroup = $usesMatch.Groups[2]
        $usesBlock = $contentGroup.Value

        # Split by comma and remove empty entries/whitespaces
        $units = $usesBlock -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

        $sysUnits = @()
        $projUnits = @()

        # Separate system units from project units (which contain " in ")
        foreach ($u in $units) {
            if ($u -match "(?i)\s+in\s+") { $projUnits += $u } else { $sysUnits += $u }
        }

        # Sort project units by relative path (the part after ' in ')
        $projUnits = $projUnits | Sort-Object { ($_ -split '(?i)\s+in\s+')[1] }

        # Reassemble the uses block
        $sortedUses = ($sysUnits + $projUnits) -join ",`r`n  "

        $spanStart = $whitespaceGroup.Index
        $spanLength = $whitespaceGroup.Length + $contentGroup.Length
        $newDprContent = $dprContent.Remove($spanStart, $spanLength).Insert($spanStart, "`r`n  $sortedUses")

        if ($dprContent -ne $newDprContent) {
            [System.IO.File]::WriteAllText($dprPath, $newDprContent, [System.Text.Encoding]::UTF8)
            Write-Host "Uses block sorted in $DprFile by relative path."
        } else {
            Write-Host "Uses block is already sorted in $DprFile."
        }
    } else {
        Write-Warning "Could not locate a 'uses ... ;' clause in $DprFile - skipping sort step."
    }
}
