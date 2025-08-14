#!/bin/bash
# Linux Docker build script for CI environments (no external cache mount)
set -euo pipefail

PRESET="${1:-default}"

echo "[host] $(date +%H:%M:%S) Building Docker image for Linux build (preset=${PRESET}) ..."
IMAGE_NAME=baresip-linux-conan:latest
DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -f docker/linux-conan.Dockerfile -t ${IMAGE_NAME} .
echo "[host] $(date +%H:%M:%S) Image ready: ${IMAGE_NAME}"

# Use local cache for CI
CONAN_CACHE_HOST="$(pwd)/.conan_ci_cache"
mkdir -p "$CONAN_CACHE_HOST"

echo "[host] $(date +%H:%M:%S) Launching container and starting Conan build ..."
docker run --rm --platform linux/amd64 \
  -v "$(pwd)":/workspace \
  -v "$CONAN_CACHE_HOST":/workspace/.conan_cache \
  -w /workspace \
  -e CONAN_NON_INTERACTIVE=1 \
  -e NINJA_STATUS="[%f/%t %o/sec] " \
  -e CMAKE_BUILD_PARALLEL_LEVEL="$(getconf _NPROCESSORS_ONLN || echo 4)" \
  -e PRESET="$PRESET" \
  ${IMAGE_NAME} bash -lc '
    set -euo pipefail
    export PS4="[container] + $(date +%H:%M:%S) "
    set -x

    echo "[container] $(date +%H:%M:%S) Setting up separate CONAN_HOME for bbconanconfig ..."
    export CONAN_HOME=/workspace/.conan_cache
    mkdir -p $CONAN_HOME
    conan profile detect --force || true
    
    echo "[container] $(date +%H:%M:%S) Setting up test-conan remote with priority ..."
    # Remove test-conan if it exists to ensure proper ordering
    conan remote remove test-conan || true
    # Add test-conan as the first remote (highest priority)
    conan remote add test-conan http://13.61.152.119:9300 --index 0
    conan remote enable test-conan
    
    # Authenticate to test-conan
    CONAN_LOGIN_USER="builder"
    CONAN_LOGIN_PASSWORD="secure123"
    conan remote login test-conan $CONAN_LOGIN_USER -p $CONAN_LOGIN_PASSWORD
    
    echo "[container] $(date +%H:%M:%S) Remote priority order:"
    conan remote list
    
    echo "[container] $(date +%H:%M:%S) Installing bbconanconfig ..."
    conan config install-pkg "bbconanconfig/[>=0.9.0]"
    
    echo "[container] $(date +%H:%M:%S) Available bbconanconfig profiles:"
    ls -la $CONAN_HOME/profiles/ | grep bb_linux_ubuntu || true
    
    PROFILE_NAME="bb_linux_ubuntu_24_10_x86_64_release_gcc_14"
    echo "[container] $(date +%H:%M:%S) Using bbconanconfig profile: ${PROFILE_NAME}"
    cat $CONAN_HOME/profiles/${PROFILE_NAME}
    
    echo "[container] $(date +%H:%M:%S) Starting conan create (may take a while on first run) ..."
    
    echo "[container] $(date +%H:%M:%S) Cleaning any old cache to ensure fresh build ..."
    
    OPTS_BASE="-o baresip/*:shared=False"
    case "${PRESET}" in
      audio)
        OPTS_PRESET="-o baresip/*:with_gstreamer=False -o baresip/*:with_gtk=False -o baresip/*:with_sdl=False -o baresip/*:with_av1=False -o baresip/*:with_ffmpeg=False -o baresip/*:with_vpx=False -o baresip/*:with_pipewire=False -o baresip/*:with_alsa=True -o baresip/*:with_pulseaudio=True -o baresip/*:with_portaudio=True" ;;
      default)
        OPTS_PRESET="-o baresip/*:with_gstreamer=False -o baresip/*:with_gtk=False -o baresip/*:with_sdl=True -o baresip/*:with_pipewire=True -o baresip/*:with_sndfile=False -o baresip/*:with_av1=True -o baresip/*:with_ffmpeg=True -o baresip/*:with_vpx=True -o baresip/*:with_pulseaudio=False -o baresip/*:with_mpg123=False" ;;
      video)
        # Video-focused without ffmpeg/gstreamer/av1/vpx to avoid zstd pull-in
        OPTS_PRESET="-o baresip/*:with_gstreamer=False -o baresip/*:with_gtk=False -o baresip/*:with_sdl=False -o baresip/*:with_av1=False -o baresip/*:with_ffmpeg=False -o baresip/*:with_vpx=False -o baresip/*:with_pipewire=False" ;;
      *)
        OPTS_PRESET="" ;;
    esac
    echo "[container] $(date +%H:%M:%S) Applying workarounds for problematic Conan packages ..."
    
    # Workaround for libtool issue - rename problematic Conan libtool binaries
    echo "Installing libtool package to cache..."
    conan install libtool/2.4.7@ --build=missing || true
    for dir in /workspace/.conan_cache/p/b/libtoa*/p/bin; do
        if [ -d "$dir" ]; then
            echo "Disabling problematic Conan libtool binaries in: $dir"
            [ -f "$dir/libtoolize" ] && mv "$dir/libtoolize" "$dir/libtoolize.broken" || true
            [ -f "$dir/libtool" ] && mv "$dir/libtool" "$dir/libtool.broken" || true
            echo "System libtool will be used instead"
        fi
    done
    
    # Workaround for bison issue - remove problematic Conan bison completely
    echo "Removing problematic Conan bison packages..."
    conan remove "bison/*" --confirm || true
    echo "System bison will be used instead (from Dockerfile)"
    
    echo "[container] $(date +%H:%M:%S) Running conan create ..."
    conan create . -pr:h ${PROFILE_NAME} -pr:b ${PROFILE_NAME} ${OPTS_BASE} ${OPTS_PRESET} \
      --build=missing -v debug
    echo "[container] $(date +%H:%M:%S) Uploading package to test-conan ..."
    conan upload "baresip/*" --remote=test-conan --confirm || true
    
    echo "[container] $(date +%H:%M:%S) Build completed successfully!"
'
echo "[host] $(date +%H:%M:%S) Docker build completed"
