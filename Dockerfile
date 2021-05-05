# Base Docker image
FROM rust:1.51.0-slim-buster

# Metadata of Docker image
LABEL maintainer="maeda.naoki.md9@gmail.com"

# Docker image build args
# Build user setting
ARG GID=10001
ARG UID=10000
ARG GroupName="BuildGroup"
ARG UserName="BuildUser"
ARG UserHomeDir="/home/BuildUser"

# Add build user (Non-root user)
RUN groupadd -g ${GID} ${GroupName} && \
    adduser -u ${UID} -S -G ${GroupName} -h ${UserHomeDir} ${UserName}

# Install Rust toolchains
RUN rustup update && \
    rustup component add rustfmt clippy rust-analysis rust-src

# Setup working user
USER $UserName
WORKDIR $UserHomeDir