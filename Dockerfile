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

# rust-analyzer
ARG RustAnalyzerReleaseURL="https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-linux"

# rust-analyzer Language Server Binary
ARG RustAnalyzerBinDirctory=${UserHomeDir}"/.local/bin/"
ARG RustAnalyzerBinPath=${RustAnalyzerBinDirctory}"rust-analyzer"

# Docker image environment variable
ENV PATH $PATH:${RustAnalyzerBinDirctory}

# Install dependencies
RUN apt update && apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Docker-cli
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | \
    gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    buster stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update && apt install -y --no-install-recommends \
    docker-ce-cli \
    && rm -rf /var/lib/apt/lists/*

# Add build user (Non-root user)
RUN groupadd -g ${GID} ${GroupName} && \
    adduser --uid ${UID} --gid ${GID} --home ${UserHomeDir} ${UserName}

# Install Rust toolchains
RUN rustup update && \
    rustup component add rustfmt clippy rust-analysis rust-src

# Download rust-analyzer language server binary
RUN mkdir -p ${RustAnalyzerBinDirctory} && \
    curl -L ${RustAnalyzerReleaseURL} -o ${RustAnalyzerBinPath} && \
    chmod +x ${RustAnalyzerBinPath}

# Setup working user
USER $UserName
WORKDIR $UserHomeDir