FROM python:3.13

COPY requirements.txt /tmp/requirements.txt

RUN python3 -m venv /tmp/checkov-venv \
    && /tmp/checkov-venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt

RUN groupadd --gid 10001 checkov \
    && useradd --no-log-init --uid 10001 --gid 10001 --create-home checkov

USER 10001:10001

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ["/tmp/checkov-venv/bin/checkov", "--version"]
