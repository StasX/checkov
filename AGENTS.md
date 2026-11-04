# Project guidance

## Purpose and scope

Build a reusable Python Docker image for Checkov infrastructure-as-code security
scanning. Keep this project focused on Checkov. This repository is a tooling image,
not a web application or a service.

## Repository map

- `Dockerfile`: Python base image and tool installation.
- `requirements.txt`: pinned Checkov dependency installed by Docker.
- `README.md`: supported tools, build/run commands, and current limitations.
- `.dockerignore`: files excluded from the image build context.
- `AGENTS.md`: shared instructions for coding assistants.
- `CLAUDE.md`: Claude Code entry point importing the shared instructions.
- `.github/copilot-instructions.md`: Copilot entry point referencing this file.
- `.github/workflows/ci.yml`: checkout, then Hadolint, Checkov, Semgrep, and Trivy
  scans of the Dockerfile. Additional CI scanners run in separate containers.
  After successful scans, builds the image and tags it using the highest Git
  version-name tag, or `0` when no Git tags exist, plus `latest`.
  Trivy scans the built image for vulnerabilities before publishing both tags to
  Docker Hub on default-branch or Git-tag runs. Pull requests never publish images.

## Working conventions

- Keep changes focused on the requested task and preserve existing user changes.
- Keep the Dockerfile at the repository root.
- Install Checkov in a virtual environment and check Python compatibility when
  updating it. Do not add unrelated scanners unless the user changes the scope.
- Prefer explicit tool versions for reproducibility. Do not invent versions or
  claim compatibility without checking and validating it.
- Update README commands when image behavior changes.
- Never add credentials, API keys, local scan targets, or generated scan reports.
- Keep machine-specific paths and personal assistant settings out of shared files.
- No OpenAI API integration is needed to build or use this image.

## Validation

For documentation-only changes, check links, command consistency, and whitespace.
For Docker or dependency changes, build and smoke-test the affected tools:

```sh
docker build -t checkov:dev .
docker run --rm checkov:dev python --version
docker run --rm checkov:dev /tmp/checkov-venv/bin/pip check
docker run --rm checkov:dev /tmp/checkov-venv/bin/checkov --version
git diff --check
```

These commands reflect the current Dockerfile. Update them when paths change.
Add a meaningful scan fixture when a change needs scan behavior verification;
keep it small and make expected scanner exit codes explicit. Do not suppress
findings just to make a check pass. Report commands run and any checks not run.

## Review focus

Check that documented commands match the image, tools can start, dependencies
are compatible, and scanner failures remain visible to callers and CI.
