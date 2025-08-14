# Building with Diff via GitHub Actions

This guide explains how to trigger a build using your local changes without creating a Pull Request.

## Overview

The `diff-build.yml` workflow allows you to:
- Apply your local changes to a branch in CI
- Build with different presets (default, video, audio)
- Download build artifacts and logs
- Test changes before committing

## Quick Start

### Option 1: Using the Script (Recommended)

```bash
# Build with default preset
./scripts/send-diff-build.sh

# Build with specific preset
./scripts/send-diff-build.sh audio

# Build against different base branch
./scripts/send-diff-build.sh default main
```

### Option 2: Manual Trigger

1. Go to [Actions → Build with Diff](../../actions/workflows/diff-build.yml)
2. Click "Run workflow"
3. Paste your diff content (from `git diff`)
4. Select build preset
5. Click "Run workflow"

## Prerequisites

### For Script Usage
- GitHub CLI installed: `brew install gh` (or see https://cli.github.com/)
- Authenticated: `gh auth login`
- `jq` installed: `brew install jq`

### For Manual Usage
- Just a web browser and your diff content

## Build Presets

- **default**: SDL, FFmpeg, VP8/VP9, AV1, PipeWire, ALSA (our new SDL-enabled build)
- **audio**: Focus on audio codecs, no video features
- **video**: Video-focused, minimal dependencies

## Getting Your Diff

```bash
# Current uncommitted changes
git diff

# Changes since last commit
git diff HEAD~1

# Changes since specific branch
git diff main
```

## Workflow Details

The GitHub Action will:
1. Check out the target branch
2. Apply your diff
3. Build using Docker (same as local builds)
4. Upload build logs and artifacts
5. Show build status

## Example Output

```bash
$ ./scripts/send-diff-build.sh default

=== Baresip Diff Build Trigger ===
Repository: alfredh/baresip
Base branch: conan-integration
Build preset: default

✓ Uncommitted changes detected
📝 Diff preview (first 20 lines):
diff --git a/conanfile.py b/conanfile.py
index abc123..def456 100644
--- a/conanfile.py
+++ b/conanfile.py
...

🚀 Triggering GitHub Action build...
✅ Build triggered successfully!
🔗 Check status at: https://github.com/alfredh/baresip/actions
```

## Troubleshooting

### Script Issues
- **"gh not found"**: Install GitHub CLI
- **"not authenticated"**: Run `gh auth login`
- **"No changes detected"**: Make some changes or commit your work

### Build Issues
- Check the Actions logs for detailed error messages
- Download build artifacts for dependency graphs and logs
- Compare with successful builds

### Diff Application Issues
- The workflow tries multiple strategies to apply diffs
- If it fails, you may need to resolve conflicts manually
- Consider rebasing your changes on the target branch first

## Local Cache vs CI

- **Local builds**: Use `/Volumes/Storage/conan-caches/baresip/cache` (persistent)
- **CI builds**: Use temporary cache (fresh every time)

This ensures CI builds are clean while your local cache is preserved.
