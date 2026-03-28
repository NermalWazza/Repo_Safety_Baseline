#requires -version 5.1

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9_.-]+$')]
    [string]$Name,

    [string]$ParentDir = (Split-Path -Parent (Resolve-Path ".")),

    [string]$BaselineRoot,

    [switch]$SkipVenv,
    [switch]$SkipGitInit,
    [switch]$SkipPreCommit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $PSBoundParameters.ContainsKey('BaselineRoot') -or [string]::IsNullOrWhiteSpace($BaselineRoot)) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $BaselineRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
}

function Write-Info {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-WarnMsg {
    param([Parameter(Mandatory = $true)][string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Ensure-Dir {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
        Write-Info "Created dir: $Path"
    }
}

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $FilePath $($Arguments -join ' ')"
    }
}

$ResolvedParentDir = (Resolve-Path -LiteralPath $ParentDir).Path
$DestinationRepo = Join-Path $ResolvedParentDir $Name
$ApplyScript = Join-Path $BaselineRoot "scripts\Setup\Apply_Baseline_To_New_Repo.ps1"

Write-Info "BaselineRoot   : $BaselineRoot"
Write-Info "ParentDir      : $ResolvedParentDir"
Write-Info "New repo path  : $DestinationRepo"

if (Test-Path -LiteralPath $DestinationRepo) {
    throw "Destination already exists: $DestinationRepo"
}

Ensure-Dir -Path $DestinationRepo

if (-not (Test-Path -LiteralPath $ApplyScript)) {
    throw "Apply script not found: $ApplyScript"
}

Write-Info "Applying baseline..."
powershell -ExecutionPolicy Bypass -File $ApplyScript -DestinationRepo $DestinationRepo
if ($LASTEXITCODE -ne 0) {
    throw "Apply_Baseline_To_New_Repo.ps1 failed."
}

if (-not $SkipGitInit) {
    Write-Info "Initialising git..."
    Push-Location $DestinationRepo
    try {
        git init | Out-Host
        if ($LASTEXITCODE -ne 0) {
            throw "git init failed."
        }

        git branch -m main 2>$null
    }
    finally {
        Pop-Location
    }
} else {
    Write-WarnMsg "Skipping git init"
}

if (-not $SkipVenv) {
    Write-Info "Creating repo-local .venv..."
    Push-Location $DestinationRepo
    try {
        py -m venv .venv
        if ($LASTEXITCODE -ne 0) {
            throw "py -m venv .venv failed."
        }
    }
    finally {
        Pop-Location
    }
} else {
    Write-WarnMsg "Skipping .venv creation"
}

if ((-not $SkipPreCommit) -and (-not $SkipVenv)) {
    Write-Info "Installing pre-commit inside .venv..."
    Push-Location $DestinationRepo
    try {
        $PythonExe = Join-Path $DestinationRepo ".venv\Scripts\python.exe"
        if (-not (Test-Path -LiteralPath $PythonExe)) {
            throw "Venv python not found: $PythonExe"
        }

        Invoke-Step -FilePath $PythonExe -Arguments @("-m", "pip", "install", "--upgrade", "pip")
        Invoke-Step -FilePath $PythonExe -Arguments @("-m", "pip", "install", "pre-commit")
        Invoke-Step -FilePath $PythonExe -Arguments @("-m", "pre_commit", "install")
        Invoke-Step -FilePath $PythonExe -Arguments @("-m", "pre_commit", "run", "--all-files")
    }
    finally {
        Pop-Location
    }
} elseif ($SkipPreCommit) {
    Write-WarnMsg "Skipping pre-commit installation"
} else {
    Write-WarnMsg "Skipping pre-commit because .venv creation was skipped"
}

Write-Host ""
Write-Host "[DONE] New repo created from baseline." -ForegroundColor Green
Write-Host "Path: $DestinationRepo" -ForegroundColor Green
Write-Host ""
Write-Host "Next commands:" -ForegroundColor Green
Write-Host "  cd `"$DestinationRepo`""
Write-Host "  git status"
Write-Host "  .\.venv\Scripts\Activate.ps1"
