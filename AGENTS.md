# Project guidance

## Purpose and scope

Build a reusable Python Docker image containing Python-based static analysis
tools. Checkov is the first installed tool. This repository is a tooling image,
not a web application or a service.

## Repository map

- `Dockerfile`: Python base image and tool installation.
- `README.md`: supported tools, build/run commands, and current limitations.
- `.dockerignore`: files excluded from the image build context.
- `AGENTS.md`: shared instructions for coding assistants.
- `CLAUDE.md`: Claude Code entry point importing the shared instructions.
- `.github/copilot-instructions.md`: Copilot entry point referencing this file.

## Working conventions

- Keep changes focused on the requested task and preserve existing user changes.
- Keep the image usable with multiple command-line tools. Do not make one scanner
  the mandatory entrypoint without a task requiring it.
- Install Python tools in virtual environments. When adding tools, check Python
  compatibility and dependency conflicts; use separate environments if necessary.
- Prefer explicit tool versions for reproducibility. Do not invent versions or
  claim compatibility without checking and validating it.
- Update README commands and the tool list when image behavior changes.
- Never add credentials, API keys, local scan targets, or generated scan reports.
- Keep machine-specific paths and personal assistant settings out of shared files.
- No OpenAI API integration is needed to build or use this image.

## Validation

For documentation-only changes, check links, command consistency, and whitespace.
For Docker or dependency changes, build and smoke-test the affected tools:

```sh
docker build -t python-sat:dev .
docker run --rm python-sat:dev python --version
docker run --rm python-sat:dev /tmp/checkov-venv/bin/pip check
docker run --rm python-sat:dev /tmp/checkov-venv/bin/checkov --version
git diff --check
```

These commands reflect the current Dockerfile. Update them when paths change.
Add a meaningful scan fixture when a change needs scan behavior verification;
keep it small and make expected scanner exit codes explicit. Do not suppress
findings just to make a check pass. Report commands run and any checks not run.

## Review focus

Check that documented commands match the image, tools can start, dependencies
are compatible, and scanner failures remain visible to callers and CI.
