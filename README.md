# Checkov Docker image

A Python-based Docker image for Checkov infrastructure-as-code security scanning.
This project is focused on Checkov only.

## Current contents

| Component | Configuration |
| --- | --- |
| Base image | `python:3.13` |
| Checkov | `3.4.3`, installed from `requirements.txt` in `/tmp/checkov-venv` |

Checkov is pinned in `requirements.txt`; transitive dependencies are not locked.
Its virtual environment is not on `PATH`, so examples use absolute paths. The
image inherits the Python base image's default command.

## Build and verify

Docker must be installed and running with Linux container support. Building
requires access to the base image registry and Python package index.

```sh
docker build -t checkov:dev .
docker run --rm checkov:dev python --version
docker run --rm checkov:dev /tmp/checkov-venv/bin/pip check
docker run --rm checkov:dev /tmp/checkov-venv/bin/checkov --version
```

## Scan a directory

Mount the directory to scan read-only at `/workspace`.

PowerShell, from the directory you want to scan:

```powershell
docker run --rm --mount "type=bind,source=$($PWD.Path),target=/workspace,readonly" checkov:dev /tmp/checkov-venv/bin/checkov -d /workspace
```

POSIX shell:

```sh
docker run --rm --mount "type=bind,source=$(pwd),target=/workspace,readonly" checkov:dev /tmp/checkov-venv/bin/checkov -d /workspace
```

Scanner findings can produce a nonzero exit code. Review the output before
treating a nonzero result as an image failure.

## Working with Codex

Repository guidance is in [AGENTS.md](AGENTS.md). It describes the project scope,
implementation conventions, validation commands, and review expectations.
This follows the repository instruction convention described in the
[official Codex documentation](https://developers.openai.com/cookbook/examples/codex/iterating-development-workflows-with-codex).

Give Codex a concrete task and the expected outcome, for example:

> Update the pinned Checkov version, document any behavior changes, and
> build and smoke-test the image.

Keep Codex authentication and personal configuration outside the repository.
No OpenAI API key is required by this Docker image.

## Working with Claude Code

[CLAUDE.md](CLAUDE.md) imports the shared [AGENTS.md](AGENTS.md) instructions
using Claude Code's [documented import syntax](https://code.claude.com/docs/en/memory#import-additional-files).
Keep common project guidance in `AGENTS.md` to avoid maintaining duplicate rules.

Start Claude Code from the repository root and give it a concrete task, as in
the Codex example above. Personal instructions in `CLAUDE.local.md` and local
permissions in `.claude/settings.local.json` are excluded from Git. No shared
permission overrides or hooks are configured.

## Working with GitHub Copilot

[.github/copilot-instructions.md](.github/copilot-instructions.md) provides
repository-wide guidance and directs Copilot to the shared
[AGENTS.md](AGENTS.md) instructions. This uses GitHub's
[repository custom instructions format](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions).

Open the repository in your Copilot-enabled IDE with repository custom
instructions enabled. In Copilot Chat, check the response's References list for
`.github/copilot-instructions.md` to confirm it was used. Instruction support
varies by Copilot feature and IDE; the link to `AGENTS.md` is a direction to read
the shared guidance, not a Claude-style automatic import.

## Next improvements

- Lock transitive dependencies for reproducible builds.
- Make tool commands available on `PATH`.
- Add automated Checkov smoke tests.
