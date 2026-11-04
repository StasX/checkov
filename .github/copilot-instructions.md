# GitHub Copilot project guidance

Read and follow [the shared project instructions](../AGENTS.md) before making
changes. Keep project conventions, validation commands, and review expectations
in `AGENTS.md` so Copilot, Codex, and Claude Code use the same guidance.

This repository builds a Python Docker image for Checkov only.
See [README.md](../README.md) for current image behavior
and build/run examples. Keep the Dockerfile at the repository root.

Preserve existing user changes. For image or dependency changes, run the build
and smoke checks from `AGENTS.md` when available, and report any checks not run.
Never commit credentials or generated scan reports.
