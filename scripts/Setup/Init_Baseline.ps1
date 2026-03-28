#requires -version 5.1

param(
    [string]$TargetRepo = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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

function Write-FileIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $ParentDir = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($ParentDir)) {
        Ensure-Dir -Path $ParentDir
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        Set-Content -Path $Path -Value $Content -Encoding UTF8
        Write-Info "Created file: $Path"
    }
    else {
        Write-WarnMsg "Exists, skipped: $Path"
    }
}

$ResolvedTargetRepo = (Resolve-Path -LiteralPath $TargetRepo).Path
Write-Info "Initialising Repo_Safety_Baseline at: $ResolvedTargetRepo"

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
    Ensure-Dir -Path (Join-Path $ResolvedTargetRepo $Dir)
}

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo ".gitignore") -Content @"
# Python
__pycache__/
*.py[cod]
*.pyo
*.pyd
.python-version
.venv/
venv/
env/

# Secrets / env
.env
.env.*
!.env.example
*.pem
*.key
*.pfx
*.p12
secrets.*
credentials.*
token.*
*.secret

# Logs / reports
*.log
_Audit_Report/
reports/

# Build / package
build/
dist/
*.egg-info/

# Node
node_modules/

# IDE / editor
.vscode/settings.json
.idea/

# OS
Thumbs.db
.DS_Store
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo ".gitattributes") -Content @"
* text=auto
*.ps1 text eol=crlf
*.sh text eol=lf
*.py text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo ".pre-commit-config.yaml") -Content @"
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: check-added-large-files
      - id: end-of-file-fixer
      - id: trailing-whitespace

  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo ".env.example") -Content @"
# Copy to .env and fill locally
# Never commit real values

OPENAI_API_KEY=
OPENAI_MODEL=gpt-4o-mini
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "README.md") -Content @"
# Repo_Safety_Baseline

Portable Git/GitHub safety starter kit for new repos.

## Purpose
Provide simple, local, inspectable controls before the first meaningful commit.

## Includes
- .gitignore baseline
- .gitattributes line-ending control
- pre-commit hooks
- secret scanning baseline
- starter templates
- docs / scripts structure

## First Use
1. Review .gitignore
2. Review .env.example
3. Install pre-commit
4. Run pre-commit install
5. Make first safe commit

## Notes
This repo is intended to be copied into new repos before app code is committed.
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "BASELINE_MANIFEST.md") -Content @"
# BASELINE_MANIFEST

## Intent
Reusable Git/GitHub safety baseline.

## Current Status
Initial folder structure and baseline starter files created.

## Planned Additions
- audit script
- repo apply script
- safer README guidance
- optional VS Code templates
- optional GitHub workflow examples

## Promotion Rule
Only add controls that are generic, safe, inspectable, and reusable.
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "templates\vscode\settings.json") -Content @"
{
  "files.autoSave": "afterDelay",
  "editor.formatOnSave": true,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true
}
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "templates\vscode\extensions.json") -Content @"
{
  "recommendations": [
    "ms-python.python",
    "ms-vscode.powershell",
    "github.vscode-github-actions"
  ]
}
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "templates\env\sample.env.example") -Content @"
# Example only
API_KEY=
API_URL=
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "templates\docs\REPO_SETUP_CHECKLIST.md") -Content @"
# REPO_SETUP_CHECKLIST

- [ ] Copy baseline into new repo
- [ ] Review .gitignore
- [ ] Create .env from .env.example
- [ ] Ensure .env is ignored
- [ ] Install pre-commit
- [ ] Run pre-commit install
- [ ] Review first commit with git status
- [ ] Confirm no secrets before push
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "scripts\Audit\README.md") -Content @"
# Audit Scripts

Place generic audit and inventory scripts here.
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "scripts\Git\README.md") -Content @"
# Git Scripts

Place generic Git safety helper scripts here.
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "scripts\Setup\README.md") -Content @"
# Setup Scripts

Place repo bootstrap and apply scripts here.
"@

Write-FileIfMissing -Path (Join-Path $ResolvedTargetRepo "docs\README.md") -Content @"
# Docs

Background notes, usage guidance, and rationale for the baseline.
"@

Write-Host ""
Write-Host "Baseline structure created successfully." -ForegroundColor Green
Write-Host "Review root files, then run the apply script again if desired." -ForegroundColor Green