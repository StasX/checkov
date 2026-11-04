FROM python:3.13-alpine

RUN apk upgrade --no-cache \
    && python3 -m pip install --no-cache-dir \
        --upgrade pip==26.3 setuptools==84.1.0

COPY requirements.txt /tmp/requirements.txt

RUN python3 -m venv /tmp/checkov-venv \
    && /tmp/checkov-venv/bin/python -m pip install --no-cache-dir \
        --upgrade pip==26.3 setuptools==84.1.0 \
    && /tmp/checkov-venv/bin/python -m pip install --no-cache-dir \
        --upgrade --upgrade-strategy eager -r /tmp/requirements.txt \
    && /tmp/checkov-venv/bin/python -m pip check

RUN addgroup --gid 10001 --system checkov \
    && adduser --uid 10001 --system --ingroup checkov --home /home/checkov \
        --no-create-home checkov \
    && mkdir -p /home/checkov \
    && chown checkov:checkov /home/checkov

USER 10001:10001
