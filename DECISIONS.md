# DECISIONS.md

## Decision — Minimal over comprehensive

Keep the baseline lean — copy only what you need.
Rationale: large baseline templates rot and stop being applied; lean ones stay current and usable.

## Decision — Pre-commit as the primary enforcement mechanism

detect-secrets + TruffleHog via pre-commit hooks.
Rationale: prevents secret leakage at commit time, before any push or PR.

## Decision — Branch strategy: nwlocal → main

`main` is the clean public branch; `nwlocal` is the local working branch.
Rationale: promotes only verified, reviewed changes to the public-facing branch.
