#!/usr/bin/env bash
set -euo pipefail

PRESET="${1:-minimal}"
echo "[host] $(date +%H:%M:%S) Building Docker image for Linux build (preset=${PRESET}) ..."

IMAGE_NAME=baresip-linux-conan:latest
DOCKER_BUILDKIT=1 docker build -f docker/linux-conan.Dockerfile -t ${IMAGE_NAME} .
echo "[host] $(date +%H:%M:%S) Image ready: ${IMAGE_NAME}"

# Mount workspace and conan cache for speed
CONAN_CACHE_HOST="$HOME/.conan2"
mkdir -p "$CONAN_CACHE_HOST"

echo "[host] $(date +%H:%M:%S) Launching container and starting Conan build ..."
docker run --rm \
  -v "$(pwd)":/workspace \
  -v "$CONAN_CACHE_HOST":/root/.conan2 \
  -w /workspace \
  -e CONAN_NON_INTERACTIVE=1 \
  -e NINJA_STATUS="[%f/%t %o/sec] " \
  -e CMAKE_BUILD_PARALLEL_LEVEL="$(getconf _NPROCESSORS_ONLN || echo 4)" \
  -e PRESET="$PRESET" \
  ${IMAGE_NAME} bash -lc '
    set -euo pipefail
    export PS4="[container] + $(date +%H:%M:%S) "
    set -x

    echo "[container] $(date +%H:%M:%S) Detecting Conan profile ..."
    conan profile detect --force || true
    conan remote list || true
    echo "[container] $(date +%H:%M:%S) Enabling and logging into remote: test-conan ..."
    conan remote enable test-conan || conan remote add test-conan http://13.61.152.119:9300 || true
    # Ensure URL is correct and credentials are applied non-interactively
    conan remote update-url test-conan http://13.61.152.119:9300 || true
    conan remote logout test-conan || true
    CONAN_LOGIN_USER="${CONAN_LOGIN_USER:-builder}"
    CONAN_LOGIN_PASSWORD="${CONAN_LOGIN_PASSWORD:-secure123}"
    conan remote login test-conan ${CONAN_LOGIN_USER} -p ${CONAN_LOGIN_PASSWORD}
    echo "[container] Enabled remotes:" && conan remote list | grep -E "\(Enabled: True\)" || true
    # Use default Conan settings; profile below specifies os.distro + version explicitly
    
    # Normalize host profile for container toolchain
    mkdir -p ~/.conan2/profiles
    ARCH_RAW=$(uname -m)
    case "$ARCH_RAW" in
      x86_64)   ARCH_SETTING=x86_64 ;;
      aarch64)  ARCH_SETTING=armv8 ;;
      arm64)    ARCH_SETTING=armv8 ;;
      *)        ARCH_SETTING=$ARCH_RAW ;;
    esac
    cat > ~/.conan2/profiles/ci <<EOF
[settings]
os=Linux
os.distro=Ubuntu
os.distro.version=24.04
arch=${ARCH_SETTING}
build_type=Release
compiler=gcc
compiler.version=13.3
compiler.libcxx=libstdc++11
compiler.cppstd=gnu17

[conf]
tools.cmake.cmaketoolchain:generator=Ninja
EOF

    echo "[container] $(date +%H:%M:%S) Using Conan host profile (ci):"
    cat ~/.conan2/profiles/ci || true

    echo "[container] $(date +%H:%M:%S) Starting conan create (may take a while on first run) ..."
    # Choose option set based on preset
    OPTS_BASE="-o baresip/*:shared=False"
    case "${PRESET}" in
      minimal)
        OPTS_PRESET="-o baresip/*:with_gstreamer=False -o baresip/*:with_gtk=False -o baresip/*:with_sdl=False -o baresip/*:with_portaudio=False -o baresip/*:with_pulseaudio=False -o baresip/*:with_alsa=False -o baresip/*:with_pipewire=False -o baresip/*:with_av1=False -o baresip/*:with_ffmpeg=False -o baresip/*:with_vpx=False" ;;
      audio)
        OPTS_PRESET="-o baresip/*:with_gstreamer=False -o baresip/*:with_gtk=False -o baresip/*:with_sdl=False -o baresip/*:with_av1=False -o baresip/*:with_ffmpeg=False -o baresip/*:with_vpx=False -o baresip/*:with_pipewire=False -o baresip/*:with_alsa=True -o baresip/*:with_pulseaudio=True -o baresip/*:with_portaudio=True" ;;
      default)
        OPTS_PRESET="-o baresip/*:with_gstreamer=False -o baresip/*:with_gtk=False -o baresip/*:with_sdl=False -o baresip/*:with_av1=False -o baresip/*:with_ffmpeg=False -o baresip/*:with_vpx=False -o baresip/*:with_pipewire=False" ;;
      *)
        OPTS_PRESET="" ;;
    esac
    conan create . -pr:h ci -pr:b ci -s build_type=Release ${OPTS_BASE} ${OPTS_PRESET} -v debug --build=missing
    echo "[container] $(date +%H:%M:%S) Uploading package to test-conan ..."
    conan upload baresip/4.0.0 -r test-conan --confirm || true
    echo "[container] $(date +%H:%M:%S) Conan create finished"
  '

echo "[host] $(date +%H:%M:%S) Build completed"


