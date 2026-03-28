# Repo_Safety_Baseline

Portable Git/GitHub safety starter kit.

---

## What this is

A minimal, reusable baseline to safely start new repositories.

It helps prevent:

- committing secrets
- bad `.gitignore` defaults
- messy repo structure
- unsafe first commits
- missing pre-commit checks

Designed for:

- Windows + VS Code
- Python or mixed repos
- solo engineers
- low-friction DevSecOps

---

## Core idea

Before writing code, you install safety rails.

This repo gives you those rails.

---

## What to copy into new repos

Take only what you need:

- `.gitignore`
- `.gitattributes`
- `.env.example`
- `.pre-commit-config.yaml`
- `scripts/Setup/`
- `scripts/Audit/`

Keep it lean.

---

## Suggested structure

    .
    ├── README.md
    ├── .gitignore
    ├── .gitattributes
    ├── .env.example
    ├── .pre-commit-config.yaml
    ├── scripts/
    │   ├── Setup/
    │   └── Audit/

---

## Quick start

### 1. Create new repo

```powershell
mkdir My_New_Project
cd My_New_Project
git init
```

---

### 2. Copy baseline files

Copy from this repo into your new project.

---

### 3. Setup environment (if Python)

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

---

### 4. Install pre-commit

```powershell
pip install pre-commit
pre-commit install
```

---

### 5. Setup environment file

```powershell
copy .env.example .env
```

Never commit `.env`.

---

### 6. Validate `.gitignore`

Ensure it excludes:

- `.env`
- `.venv/`
- logs
- cache
- OS junk
- editor state

---

### 7. First commit (safe)

```powershell
git add .
git commit -m "Initial safe baseline"
```

If hooks modify files, re-add and commit again.

---

## Safety checklist (before push)

- No `.env` committed
- No API keys in code
- Pre-commit installed
- README present
- Repo structure clean
- No large unintended files

---

## Branch strategy

Recommended:

- `main` → clean public branch (GitHub)
- `YourLocal` → your local working branch

---

## Publish to GitHub

```powershell
git remote add origin https://github.com/NermalWazza/Repo_Safety_Baseline.git
git push -u origin master:main
```

---

## Optional: switch local branch

```powershell
git branch -m nwlocal
git branch --set-upstream-to=origin/main nwlocal
```

---

## Ongoing workflow

```powershell
git push
git pull
```

---

## Philosophy

- simple > complex
- local control > hidden automation
- prevent mistakes early
- make safety the default

---

## Future improvements

- repo generator script
- language-specific templates
- GitHub Actions checks
- improved secret scanning

---

## Author

Built from real-world mistakes and recovery patterns.
