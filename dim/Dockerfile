# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.9-slim-bullseye
FROM python:${PYTHON_VERSION}

# Install build dependencies and MariaDB client (replacement for libmysqlclient-dev)
RUN apt update \
    && apt install --no-install-suggests --no-install-recommends -y \
    pkg-config gcc curl wget gnupg lsb-release python3-dev libmariadb-dev libmariadb-dev-compat \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install Python dependencies
RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install --no-cache-dir -r requirements.txt \
    && apt purge -y pkg-config gcc curl wget gnupg lsb-release python3-dev \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    dimuser

WORKDIR /dim

RUN mkdir /etc/dim && chown dimuser:dimuser /etc/dim

COPY --chown=dimuser:dimuser . .

USER dimuser

CMD ["gunicorn", "app:application", "-w", "4", "-b", ":8000"]
