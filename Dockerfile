# Base Docker image
FROM rust:1.52.1-slim-buster

# Metadata of Docker image
LABEL maintainer="maeda.naoki.md9@gmail.com"

# Docker image build args
# Build user setting
ARG GID=10001
ARG UID=10000
ARG GroupName="DevelopGroup"
ARG UserName="developer"
ARG UserHomeDir="/home/developer"

# Install dependencies
RUN apt update && apt install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add build user (Non-root user)
RUN groupadd -g ${GID} ${GroupName} && \
    adduser --uid ${UID} --gid ${GID} --home ${UserHomeDir} ${UserName}

# Install Rust toolchains
RUN rustup update && \
    rustup component add rustfmt clippy rust-analysis rust-src

# Setup working user
USER $UserName
WORKDIR $UserHomeDir