param(
    [string[]]$libPath,
    [string]$workflowPath=".\workflows",
    [string]$bootstrapperPath="..\.bonsai\Bonsai.exe"
)

function Export-Svg([string[]]$libPath, [string]$svgFileName, [string]$workflowFile)
{
    $bootstrapperArgs = @()
    foreach ($path in $libPath) {
        $bootstrapperArgs += "--lib"
        $bootstrapperArgs += "$(Resolve-Path $path)"
    }
    $bootstrapperArgs += "--export-image"
    $bootstrapperArgs += "$svgFileName"
    $bootstrapperArgs += "$workflowFile"

    Write-Verbose "$($bootstrapperPath) $($bootstrapperArgs)"
    &$bootstrapperPath $bootstrapperArgs
}

Import-Module (Join-Path $PSScriptRoot "Export-Tools.psm1")
$sessionPath = $ExecutionContext.SessionState.Path
foreach ($workflowFile in Get-ChildItem -File -Recurse (Join-Path $workflowPath "*.bonsai")) {
    $svgFileName = "$($workflowFile.BaseName).svg"
    Write-Host "Exporting $($svgFileName)"
    $svgFileDirectory = Split-Path -Parent $workflowFile.FullName
    $svgFile = $sessionPath.GetUnresolvedProviderPathFromPSPath((Join-Path $svgFileDirectory $svgFileName))
    Export-Svg $libPath $svgFileName $workflowFile
    Convert-Svg $svgFile
}