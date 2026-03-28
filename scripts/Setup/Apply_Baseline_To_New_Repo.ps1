#requires -version 5.1

param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DestinationRepo,

    [string]$BaselineRoot,

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $PSBoundParameters.ContainsKey('BaselineRoot') -or [string]::IsNullOrWhiteSpace($BaselineRoot)) {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $BaselineRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
}

function Write-Info {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-WarnMsg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Ensure-Dir {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
        Write-Info "Created dir: $Path"
    }
}

function Copy-FileSafe {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination,

        [Parameter(Mandatory = $true)]
        [bool]$Overwrite
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-WarnMsg "Missing source, skipped: $Source"
        return
    }

    $ParentDir = Split-Path -Parent $Destination
    Ensure-Dir -Path $ParentDir

    if ((Test-Path -LiteralPath $Destination) -and (-not $Overwrite)) {
        Write-WarnMsg "Exists, skipped: $Destination"
        return
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Info "Copied: $Source -> $Destination"
}

function Write-FileIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $ParentDir = Split-Path -Parent $Path
    Ensure-Dir -Path $ParentDir

    if (-not (Test-Path -LiteralPath $Path)) {
        Set-Content -Path $Path -Value $Content -Encoding UTF8
        Write-Info "Created file: $Path"
    }
    else {
        Write-WarnMsg "Exists, skipped: $Path"
    }
}

$ResolvedDestinationRepo = (Resolve-Path -LiteralPath $DestinationRepo).Path

if (-not (Test-Path -LiteralPath $ResolvedDestinationRepo)) {
    throw "Destination repo not found: $DestinationRepo"
}

Write-Info "Applying baseline"
Write-Info "BaselineRoot   : $BaselineRoot"
Write-Info "DestinationRepo: $ResolvedDestinationRepo"

$BaselineFiles = @(
    ".gitignore",
    ".gitattributes",
    ".pre-commit-config.yaml",
    ".env.example",
    "README.md",
    "BASELINE_MANIFEST.md"
)

foreach ($File in $BaselineFiles) {
    $SourcePath = Join-Path $BaselineRoot $File
    $DestinationPath = Join-Path $ResolvedDestinationRepo $File
    Copy-FileSafe -Source $SourcePath -Destination $DestinationPath -Overwrite $Force.IsPresent
}

$Dirs = @(
    ".github",
    ".github\workflows",
    "hooks",
    "scripts",
    "scripts\Setup",
    "scripts\Audit",
    "scripts\Git",
    "templates",
    "templates\env",
    "templates\docs",
    "templates\vscode",
    "examples",
    "docs"
)

foreach ($Dir in $Dirs) {
    Ensure-Dir -Path (Join-Path $ResolvedDestinationRepo $Dir)
}

$TemplateFiles = @(
    "templates\vscode\settings.json",
    "templates\vscode\extensions.json",
    "templates\env\sample.env.example",
    "templates\docs\REPO_SETUP_CHECKLIST.md",
    "scripts\Audit\README.md",
    "scripts\Git\README.md",
    "scripts\Setup\README.md",
    "docs\README.md"
)

foreach ($File in $TemplateFiles) {
    $SourcePath = Join-Path $BaselineRoot $File
    $DestinationPath = Join-Path $ResolvedDestinationRepo $File
    Copy-FileSafe -Source $SourcePath -Destination $DestinationPath -Overwrite $Force.IsPresent
}

Write-FileIfMissing -Path (Join-Path $ResolvedDestinationRepo "NEXT_STEPS.md") -Content @"
# NEXT_STEPS

- Review .gitignore
- Review .env.example
- Confirm no real secrets exist in the repo
- Install pre-commit:
  pip install pre-commit
  pre-commit install
- Run:
  git status
- Make the first safe commit
"@

Write-Host ""
Write-Host "Baseline applied successfully." -ForegroundColor Green
Write-Host "Recommended next commands:" -ForegroundColor Green
Write-Host "  cd `"$ResolvedDestinationRepo`""
Write-Host "  git status"
Write-Host "  pre-commit install"