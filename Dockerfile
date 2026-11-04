FROM python:3.13

COPY requirements.txt /tmp/requirements.txt

RUN python3 -m venv /tmp/checkov-venv \
    && /tmp/checkov-venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt
