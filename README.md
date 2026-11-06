# Checkov Docker image

A Python-based Docker image for Checkov infrastructure-as-code security scanning.
This project is focused on Checkov only.

## Current contents

| Component | Configuration |
| --- | --- |
| Base image | `python:3.13` |
| Checkov | `3.4.3`, installed from `requirements.txt` in `/tmp/checkov-venv` |
| Runtime user | Non-root `checkov` user (UID/GID `10001`) with a home directory |
| Health check | Runs `checkov --version` every 30 seconds |

Checkov is pinned in `requirements.txt`; transitive dependencies are not locked.
The build upgrades installed Debian packages and pip to `26.3` in system Python and
Checkov's virtual environment. Python dependencies
are upgraded to the newest versions permitted by Checkov's dependency constraints.
Checkov itself stays at the version in `requirements.txt`. Available upgrades
do not necessarily fix every reported vulnerability.
CI uses `--pull --no-cache` to prevent cached layers from skipping the upgrade
commands. Setuptools and wheel are not explicitly installed.
Its virtual environment is not on `PATH`, so examples use absolute paths. The
image inherits the Python base image's default command.

The image does not define a Docker health check. Bind-mounted scan targets must
be readable by the container's non-root user.

## Build and verify

Docker must be installed and running with Linux container support. Building
requires access to the base image registry and Python package index.

```sh
docker build --pull --no-cache -t checkov:dev .
docker run --rm checkov:dev python --version
docker run --rm checkov:dev /tmp/checkov-venv/bin/pip check
docker run --rm checkov:dev /tmp/checkov-venv/bin/checkov --version
```

## Continuous integration

[GitHub Actions](.github/workflows/main.yml) runs on pushes, pull requests, and
manual runs in this order:

1. Check out the repository.
2. Lint the root `Dockerfile` with Hadolint `2.15.1`.
3. Scan it using the official Checkov `3.4.3` image.
4. Scan it with Semgrep `1.183.0` and the `p/dockerfile` ruleset.
5. Scan its configuration with Trivy `0.76.1`, using the repository's narrow
   Rego ignore policy for the intentionally omitted health check.
6. Build the Docker image as `checkov:build` if all scans pass.
7. Tag the built image as `checkov:<latest-git-tag>` and `checkov:latest`.
8. Scan the built image's OS and application dependencies with Trivy.
9. Log in and push both tags to Docker Hub (eligible runs only).
10. Upload available scan reports and build artifacts, even if previous steps fail.

Later scanners run even when an earlier scanner fails, provided checkout
succeeded and the run was not cancelled. Findings or scanner errors fail the
workflow. The Trivy image scan excludes `/tmp/checkov-venv` and `.git`
directories (including nested ones) as requested;
Checkov and its Python dependencies in that environment are outside its coverage.

Each scanner has its own artifact in the run's **Artifacts** section, retained
for 14 days. Names end with `<run-id>-<attempt>`:

| Artifact prefix | Contents |
| --- | --- |
| `hadolint-reports` | `hadolint.json` and diagnostic log |
| `checkov-reports` | `checkov.json` and diagnostic log |
| `semgrep-reports` | `semgrep.json` and diagnostic log |
| `trivy-dockerfile-reports` | `trivy-dockerfile.json` and diagnostic log |
| `trivy-image-reports` | `trivy-image.json` and diagnostic log |
| `build-reports` | Build log and image metadata, when available |

Passing scans still generate JSON reports, even with zero findings. Reports are
uploaded after failures too. Skipped scans have no artifact. Credentials and
Docker login output are not included.

Logs remain visible in the Actions console. Bash `pipefail` preserves scanner
and build failures when output is copied into artifact files with `tee`.

Semgrep uses strict mode, so parsing warnings also fail its step. The Dockerfile
uses LF line endings, enforced by `.gitattributes`, for consistent parsing.

Each scanner runs in a separate container; the project image still contains only
Checkov. Trivy first scans Dockerfile misconfigurations and later scans the built
image outside `/tmp/checkov-venv` for vulnerabilities at all severities,
including those without fixes.
Image vulnerabilities or scanner errors block publishing.
Semgrep downloads its registry rules and Trivy may download updated checks, so
these scans require network access and rules may change independently of tool
versions.

Checkout fetches all history and tags. The tagging step selects the highest tag
using Git's version-name sort (`git tag --sort=-version:refname`), not the newest
tag by creation date or a GitHub Release's `latest` designation. For example,
`v1.10.0` sorts ahead of `v1.9.0`, producing `checkov:v1.10.0`. Tag names must be
valid Docker tags. If the repository has no tags, the image uses version `0`
(`checkov:0`). This fallback does not create a Git tag. The same image also gets
the `checkov:latest` tag in every successful build.

The image contains the checked-out commit, including on branch and pull-request
runs; the version tag is used as a label, not as a different source checkout.
Published images are tagged as `docker.io/<dockerhub-username>/checkov:<version>`
and `docker.io/<dockerhub-username>/checkov:latest`.

Publishing runs only after every scan passes, on default-branch and Git-tag runs.
Manual runs must target the default branch or a tag to publish. Pull requests and
other branches build and scan without publishing.

In GitHub repository **Settings > Secrets and variables > Actions**, add:

- `DOCKERHUB_USERNAME`: your Docker Hub username.
- `DOCKERHUB_TOKEN`: a Docker Hub access token with permission to push images.

Create the `checkov` repository under that Docker Hub account and make sure the
token can push to it. See Docker's [access token documentation](https://docs.docker.com/security/access-tokens/).
GitHub hosts the workflow; Docker Hub stores the published images.

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

## License

This project is licensed under the [MIT License](LICENSE).
