# Baresip Conan Installation Guide for macOS

This guide explains how to install and run baresip built with Conan on macOS (Apple Silicon).

## Prerequisites

### System Requirements
- **macOS**: 12.0+ (Apple Silicon M1/M2/M3)
- **Xcode**: Latest version with command line tools
- **Python**: 3.8+ (for Conan)

### Required Tools

1. **Install Homebrew** (if not already installed):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. **Install Conan 2.x**:
```bash
pip install "conan>=2.0"
```

3. **Verify Conan installation**:
```bash
conan --version
# Should show Conan 2.x
```

## Conan Configuration

### 1. Set Up Conan Profile

Create a Conan profile for macOS Apple Silicon:

```bash
# Create default profile
conan profile detect --force

# Verify the profile
conan profile show default
```

Your profile should look similar to:
```ini
[settings]
arch=armv8
build_type=Release
compiler=apple-clang
compiler.cppstd=gnu17
compiler.libcxx=libc++
compiler.version=17
os=Macos
```

### 2. Add Remote Repositories

Add the required Conan remotes:

```bash
# Add the test-conan remote (primary)
conan remote add test-conan http://13.61.152.119:9300

# Verify conancenter is available (fallback)
conan remote list
```

**Expected output:**
```
test-conan: http://13.61.152.119:9300 [Verify SSL: True, Enabled: True]
conancenter: https://center2.conan.io [Verify SSL: True, Enabled: True]
```

### 3. Authentication Setup

The test-conan remote requires authentication. Contact your administrator for:
- Username
- Password/API key

Then authenticate:
```bash
conan remote login test-conan <your-username>
# Enter password when prompted
```

### 4. Install Conan Configuration Package

```bash
# Install the configuration package
conan config install-pkg bbconanconfig/0.9.5
```

## Installing Baresip

### Method 1: Deploy Pre-built Application (Recommended)

```bash
# Create a directory for your deployment
mkdir baresip-app && cd baresip-app

# Create a conanfile.txt for the application
cat > conanfile.txt << EOF
[requires]
baresip/4.0.0

[options]
baresip/*:with_sdl=True
baresip/*:with_ffmpeg=False
baresip/*:with_gstreamer=False
baresip/*:with_sndfile=False
baresip/*:with_av1=False

[generators]
VirtualBuildEnv
EOF

# Deploy the complete application with all dependencies
conan install . -d full_deploy

# This creates a 'full_deploy' folder with the complete baresip application
# Alternative deployers:
# -d direct_deploy   (just the baresip package, no dependencies)
# -d runtime_deploy  (only runtime libraries needed to run baresip)
```

### Method 2: Build from Source

```bash
# Clone the repository
git clone <baresip-repo-url>
cd baresip

# Checkout the conan-integration branch
git checkout conan-integration

# Build with Conan
conan create . --profile default \
  -o 'baresip/*:with_sdl=True' \
  -o 'baresip/*:with_ffmpeg=False' \
  -o 'baresip/*:with_gstreamer=False' \
  -o 'baresip/*:with_sndfile=False' \
  -o 'baresip/*:with_av1=False' \
  --build=missing
```

## Running Baresip

### 1. Locate the Deployed Application

After deployment, the baresip application is ready to run:

```bash
# Navigate to your deployment directory
cd baresip-app

# The deployed application is in the full_deploy folder
ls full_deploy/host/baresip/4.0.0/Release/armv8/

# Run baresip from the deployed location
./full_deploy/host/baresip/4.0.0/Release/armv8/bin/baresip
```

### 2. Configure Baresip

Create or update the baresip configuration:

```bash
# Create config directory
mkdir -p ~/.baresip

# Create a minimal config file for Conan builds
cat > ~/.baresip/config << 'EOF'
# Baresip configuration for Conan builds

#------------------------------------------------------------------------------
# SIP
sip_cafile		/etc/ssl/cert.pem

# Audio
audio_level		no
ausrc_format		s16
auplay_format		s16
auenc_format		s16
audec_format		s16
audio_buffer		20-160
audio_buffer_mode	fixed
audio_silence		-35.0
audio_telev_pt		101

# Video
video_size		640x480
video_bitrate		1000000
video_fps		30.00
video_fullscreen	yes
videnc_format		yuv420p

# Network
rtp_tos			184
rtp_video_tos		136

#------------------------------------------------------------------------------
# Modules - Only include modules that are built

# UI Modules
module			stdio.so
module			httpd.so

# Audio codec Modules
module			opus.so

# Audio filter Modules
module			auconv.so
module			auresamp.so
module			vumeter.so

# Audio driver Modules
module			coreaudio.so

# Video codec Modules
module			av1.so

# Video filter Modules
module			selfview.so
module			snapshot.so
module			vidinfo.so

# Video source modules
module			avcapture.so

# Video display modules
module			sdl.so
module			fakevideo.so

# Compatibility modules
module			uuid.so

# Media NAT modules
module			stun.so
module			turn.so
module			ice.so

#------------------------------------------------------------------------------
# Application Modules

module_app		account.so
module_app		contact.so
module_app		debug_cmd.so
module_app		menu.so
module_app		netroam.so

#------------------------------------------------------------------------------
# Module parameters

# HTTP Server
http_listen		0.0.0.0:8000

# Selfview
video_selfview		window

# Menu
ringback_disabled	no
EOF
```

### 3. Run Baresip

```bash
# Run baresip from the deployed location
./full_deploy/host/baresip/4.0.0/Release/armv8/bin/baresip

# Or with version info
./full_deploy/host/baresip/4.0.0/Release/armv8/bin/baresip --version

# Or make it globally available by adding to PATH
export PATH="$(pwd)/full_deploy/host/baresip/4.0.0/Release/armv8/bin:$PATH"
baresip --version
```

## Features Enabled

This Conan build includes:

✅ **Audio Support**:
- Opus codec
- CoreAudio driver (macOS native)
- Audio filtering (convert, resample, volume meter)

✅ **Video Support**:
- AV1 codec
- SDL display
- AVCapture source (macOS camera)
- Video filters (selfview, snapshot, info)

✅ **Network Features**:
- STUN/TURN/ICE protocols
- HTTP interface (port 8000)

❌ **Disabled Features** (to avoid dependency issues):
- FFmpeg codecs (H.264/H.265)
- GStreamer
- sndfile
- PulseAudio/ALSA

## Troubleshooting

### Common Issues

1. **Module loading errors**: 
   - Check that your `~/.baresip/config` only lists modules that are actually built
   - The config above matches the enabled build features

2. **Permission denied**:
   ```bash
   chmod +x <path-to-baresip-binary>
   ```

3. **SSL Certificate issues**:
   ```bash
   # Update certificates
   brew install ca-certificates
   ```

4. **Audio/Video device access**:
   - Grant microphone/camera permissions when prompted
   - Check System Preferences → Security & Privacy

### Getting Help

- Check baresip logs in the terminal output
- Use the HTTP interface at `http://localhost:8000` for web control
- Enable debug mode: `baresip -v` for verbose output

## Building Custom Configurations

To build with different features, modify the options:

```bash
# Enable different features
conan create . --profile default \
  -o 'baresip/*:with_sdl=True' \
  -o 'baresip/*:with_ffmpeg=True' \
  -o 'baresip/*:with_vpx=True' \
  --build=missing
```

Available options:
- `with_sdl` - SDL video support
- `with_ffmpeg` - FFmpeg codecs (H.264/H.265)
- `with_gstreamer` - GStreamer support
- `with_gtk` - GTK GUI
- `with_pulseaudio` - PulseAudio support
- `with_av1` - AV1 video codec
- `with_vpx` - VP8/VP9 codecs

## Version Information

- **Baresip**: 4.0.0
- **Platform**: macOS Apple Silicon (ARM64)
- **Build System**: Conan 2.x + CMake
- **Compiler**: Apple Clang 17.0

## Quick Installation Summary

```bash
# 1. Setup Conan
pip install "conan>=2.0"
conan profile detect --force
conan remote add test-conan http://13.61.152.119:9300
conan remote login test-conan <username>
conan config install-pkg bbconanconfig/0.9.5

# 2. Deploy baresip application
mkdir baresip-app && cd baresip-app
cat > conanfile.txt << 'EOF'
[requires]
baresip/4.0.0

[options]
baresip/*:with_sdl=True
baresip/*:with_pipewire=True

[generators]
VirtualBuildEnv
EOF
conan install . -d full_deploy

# 3. Run baresip
./full_deploy/host/baresip/4.0.0/Release/armv8/bin/baresip --version
```

## CI/CD Integration

This project uses modern Conan-based GitHub Actions workflows:

### Active Workflows:
- **🍎 Conan macOS Build** - Builds using `bb_macos_15_5_armv8_release_apple-clang_17_0` profile
- **🐧 Conan Linux Build** - Builds using `bb_linux_ubuntu_24_10_x86_64_release_gcc_14` profile  
- **🔍 Lint Check** - Code quality checks (ccheck, CMakeLint, pylint)

### Workflow Features:
- Uses `conan create` with `--build=missing` for efficient dependency management
- Automatic upload of built packages to test-conan artifactory
- Version verification tests to ensure correct v4.0.0 deployment
- Profile-based builds using bbconanconfig package from artifactory

### Legacy Workflows:
Legacy workflows (build.yml, windows.yml, fedora.yml, etc.) are automatically disabled when `conanfile.py` is present, ensuring clean CI runs focused on Conan integration.

## Contact

For issues or questions about this Conan build, contact your development team.
# Test workflow with authentication secrets
