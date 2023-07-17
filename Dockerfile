# Setup Docker image
FROM rust:1.71.0-slim-bookworm AS setup

# rust-analyzer
ARG RustAnalyzerReleaseURL="https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz"
ARG RustAnalyzerTempBinPath="/tmp/rust-analyzer"

# Install dependencies
RUN apt update && apt install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Install Docker-cli
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update && apt install -y --no-install-recommends \
    docker-ce-cli

# Install Rust toolchains
RUN rustup update && \
    rustup component add rustfmt clippy rust-analysis rust-src && \
    # Install cross(Docker remote support ver)
    cargo install --git https://github.com/schrieveslaach/cross/ --branch docker-remote

# =================================================================================================

# Base Docker image
FROM rust:1.71.0-slim-bookworm

# Metadata of Docker image
LABEL maintainer="maeda.naoki.md9@gmail.com"
LABEL version="1.0.0"

# Docker image build args
# Build user setting
ARG GID=10001
ARG UID=10000
ARG GroupName="DevelopGroup"
ARG UserName="developer"
ARG UserHomeDir="/home/developer"

# rust-analyzer Language Server Binary
ARG RustAnalyzerTempBinPath="/tmp/rust-analyzer"

# Add build user (Non-root user)
RUN groupadd -g ${GID} ${GroupName} && \
    adduser --uid ${UID} --gid ${GID} --home ${UserHomeDir} ${UserName}

# Copy Docker cli binary
COPY --from=setup /usr/bin/docker /usr/bin/docker

# Copy rust directory
RUN  rm -rf /usr/local/cargo /usr/local/rustup
COPY --from=setup --chown=${UID}:${GID} /usr/local/cargo/   /usr/local/cargo/
COPY --from=setup --chown=${UID}:${GID} /usr/local/rustup/  /usr/local/rustup/

# Setup working user
USER ${UID}
WORKDIR ${UserHomeDir}
