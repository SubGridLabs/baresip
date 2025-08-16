FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        wget \
        gnupg \
        ca-certificates \
        curl && \
    apt-get install -y --no-install-recommends \
        gcc-14 \
        g++-14 \
        clang \
        cmake \
        ninja-build \
        meson \
        pkg-config \
        pkgconf \
        libasound2-dev \
        libva-dev \
        libvdpau-dev \
        libegl1-mesa-dev \
        libx11-dev \
        libx11-xcb-dev \
        libxext-dev \
        libxfixes-dev \
        libxau-dev \
        libxrandr-dev \
        libxrender-dev \
        libxi-dev \
        libxtst-dev \
        libxcb1-dev \
        libxcb-glx0-dev \
        libxcb-render0-dev \
        libxcb-xkb-dev \
        libxcb-icccm4-dev \
        libxcb-image0-dev \
        libxcb-keysyms1-dev \
        libxcb-randr0-dev \
        libxcb-shape0-dev \
        libxcb-sync-dev \
        libxcb-xfixes0-dev \
        libxcb-xinerama0-dev \
        uuid-dev \
        libfontenc-dev \
        libice-dev \
        libsm-dev \
        libxaw7-dev \
        libxcomposite-dev \
        libxcursor-dev \
        libxdamage-dev \
        libxinerama-dev \
        libxkbfile-dev \
        libxmu-dev \
        libxmuu-dev \
        libxpm-dev \
        libxres-dev \
        libxss-dev \
        libxt-dev \
        libxv-dev \
        libxxf86vm-dev \
        libxcb-render-util0-dev \
        libxcb-dri3-dev \
        libxcb-cursor-dev \
            libxcb-dri2-0-dev \
    libxcb-present-dev \
    libxcb-composite0-dev \
    libxcb-ewmh-dev \
    libxcb-res0-dev \
    xkb-data \
        libxcb-util-dev \
        libxcb-util0-dev \
        libxcb-render-util0-dev \
        git \
        python3 \
        python3-venv \
        pipx \
        zstd \
        libzstd-dev \
        make \
        m4 \
        autoconf \
        automake \
        libtool \
        libtool-bin \
        autotools-dev \
        pkg-config \
        bison \
        flex \
        libva-dev \
        libva-drm2 \
        libva-x11-2 \
        libva-wayland2 \
        va-driver-all && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 100 && \
    rm -rf /var/lib/apt/lists/*

# Conan 2 via pipx (avoids PEP 668 issues) - use recent version for bbconanconfig compatibility
ENV PATH="/root/.local/bin:${PATH}"
RUN pipx install "conan>=2.19,<3"

WORKDIR /workspace

# Default command opens a shell; our script will override with build commands
CMD ["bash"]


