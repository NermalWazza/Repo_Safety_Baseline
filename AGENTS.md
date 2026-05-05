# AGENTS.md

## What this repo is

A portable Git/GitHub safety starter kit. Provides template files to be copied into new repositories to establish secret scanning, gitignore defaults, and pre-commit enforcement. Markdown and config files only — no runtime code.

## Confirmed commands

None in this repo. Commands are in the scripts intended for use in target repos.

## Key artefacts (copy to new repos as needed)

| File/Folder | Purpose |
|-------------|---------|
| `.gitignore` | Baseline ignore rules |
| `.gitattributes` | Line-ending and binary handling |
| `.env.example` | Environment variable template |
| `.pre-commit-config.yaml` | Secret scanning hooks (detect-secrets + TruffleHog) |
| `scripts/Setup/` | Environment setup scripts for target repos |
| `scripts/Audit/` | Audit scripts for target repos |

## Guardrails

- Do not add application code or runtime logic to this repo.
- Keep templates minimal — large templates rot and stop getting used.
- Changes here may propagate to all repos that adopt the baseline.

## Branch model

`nwlocal` → `main`.
