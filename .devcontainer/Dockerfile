FROM mcr.microsoft.com/devcontainers/base:noble

RUN apt-get update && \
    apt-get install -y \
        libfontconfig1 \
        jq \
    && \
    rm -rf /var/lib/apt/lists/*
