# Setup Docker image
FROM rust:1.56.0-slim-bullseye AS setup

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
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | \
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update && apt install -y --no-install-recommends \
    docker-ce-cli

# Download rust-analyzer language server binary
RUN curl -L ${RustAnalyzerReleaseURL} | gunzip -c - > ${RustAnalyzerTempBinPath} && \
    chmod +x ${RustAnalyzerTempBinPath}

# Install Rust toolchains
RUN rustup update && \
    rustup component add rustfmt clippy rust-analysis rust-src && \
    # Install cross(Docker remote support ver)
    cargo install --git https://github.com/schrieveslaach/cross/ --branch docker-remote

# =================================================================================================

# Base Docker image
FROM rust:1.56.0-slim-bullseye

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
ARG RustAnalyzerBinDirctory=${UserHomeDir}"/.local/bin/"
ARG RustAnalyzerBinPath=${RustAnalyzerBinDirctory}"rust-analyzer"

# Docker image environment variable
ENV PATH $PATH:${RustAnalyzerBinDirctory}

# Add build user (Non-root user)
RUN groupadd -g ${GID} ${GroupName} && \
    adduser --uid ${UID} --gid ${GID} --home ${UserHomeDir} ${UserName}

# Copy Docker cli binary
COPY --from=setup /usr/bin/docker /usr/bin/docker

# Copy rust-analyzer language server binary
COPY --from=setup ${RustAnalyzerTempBinPath} ${RustAnalyzerBinPath}

# Copy rust directory
RUN  rm -rf /usr/local/cargo /usr/local/rustup
COPY --from=setup --chown=${UID}:${GID} /usr/local/cargo/   /usr/local/cargo/
COPY --from=setup --chown=${UID}:${GID} /usr/local/rustup/  /usr/local/rustup/

# Setup working user
USER ${UID}
WORKDIR ${UserHomeDir}
