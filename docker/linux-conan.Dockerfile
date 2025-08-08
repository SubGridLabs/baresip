FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        cmake \
        ninja-build \
        pkg-config \
        libasound2-dev \
        git \
        python3 \
        python3-venv \
        pipx \
        zstd \
        libzstd-dev \
        ca-certificates \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Conan 2 via pipx (avoids PEP 668 issues)
ENV PATH="/root/.local/bin:${PATH}"
RUN pipx install "conan>=2,<3"

WORKDIR /workspace

# Default command opens a shell; our script will override with build commands
CMD ["bash"]


