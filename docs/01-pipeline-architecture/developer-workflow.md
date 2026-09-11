# ForgePay Developer Hygiene & Local Workflow Guide

## AI Attribution Block
AI-assisted developer documentation detailing workstation pre-flight checks and conventional commit enforcement.

## Overview

To maintain zero-defect trunk hygiene on the protected `main` branch, all ForgePay contributors must adhere to local verification gates prior to pushing pull requests:

### 1. Pre-Commit Hooks
Run automatically before every commit to strip trailing whitespaces, format JSON/YAML files, and check max file size bounds:
```bash
pre-commit install --hook-type pre-commit --hook-type commit-msg
```

### 2. Conventional Commit Standards
All commits must strictly follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:
$$\text{<type>(<scope>): <subject>}$$
Valid types: `feat`, `fix`, `docs`, `chore`, `perf`, `refactor`, `test`, `ci`, `build`.
