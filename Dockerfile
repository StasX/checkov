FROM python:3.13

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --upgrade pip==26.3

COPY requirements.txt /tmp/requirements.txt

RUN python3 -m venv /tmp/checkov-venv \
    && /tmp/checkov-venv/bin/python -m pip install --no-cache-dir --upgrade pip==26.3 \
    && /tmp/checkov-venv/bin/python -m pip install --no-cache-dir \
        --upgrade --upgrade-strategy eager -r /tmp/requirements.txt \
    && /tmp/checkov-venv/bin/python -m pip check

RUN groupadd --gid 10001 checkov \
    && useradd --no-log-init --uid 10001 --gid 10001 --create-home checkov

USER 10001:10001

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ["/tmp/checkov-venv/bin/checkov", "--version"]
