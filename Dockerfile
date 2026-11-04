FROM python:3.13

RUN python3 -m venv /tmp/checkov-venv \
    && /tmp/checkov-venv/bin/pip install --no-cache-dir checkov
