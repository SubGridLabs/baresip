# baresip CI/CD Performance Optimization Summary

## Performance Journey

### Cold Build Baseline
- **Time**: 24 minutes 28 seconds (1,468 seconds)
- **Description**: Complete build of entire dependency graph from scratch using `--build='*'`
- **Purpose**: Establishes the true cost of building everything without any optimizations

### Before Optimizations
- **Time**: ~10.0 minutes
- **Issues**: 
  - FFmpeg and other dependencies rebuilt on every CI run
  - No package upload logic
  - No caching

### With Package Upload Logic  
- **Time**: ~6.1 minutes  
- **Improvement**: 39% faster than baseline, 75% faster than cold build
- **Key Changes**:
  - Fixed package detection using `grep`/`sed` with proper timing (`sync && sleep 2`)
  - Upload newly built packages to Artifactory
  - Fixed Linux Docker file persistence issues
  - Disabled problematic `libx265` builds

### With GitHub Actions Cache
- **Time**: ~2.1 minutes
- **Improvement**: 79% faster than baseline, 91% faster than cold build  
- **Key Changes**:
  - Added GitHub Actions caching for Conan packages (`actions/cache@v4`)
  - Unified `CONAN_HOME` between build and test jobs
  - Cache sharing prevents re-downloading packages

## Key Technical Fixes

### 1. Package Detection & Upload
- **Problem**: CI was rebuilding expensive dependencies (FFmpeg) on every run
- **Solution**: Improved log scraping with `tee`, `sync`, and precise `sed` patterns
- **Result**: Packages uploaded to Artifactory for reuse

### 2. Linux Docker Persistence  
- **Problem**: `built_packages.txt` lost between Docker containers
- **Solution**: Write to mounted volume (`/workspace/built_packages.txt`)
- **Result**: Reliable package upload detection

### 3. macOS Test Job Failures
- **Problem**: Package ID extraction with line breaks, hardcoded library versions
- **Solution**: `tr -d '\n'` for clean IDs, generic `libbaresip.*.dylib` pattern
- **Result**: Stable test execution

### 4. GitHub Actions Cache Sharing
- **Problem**: Build and test jobs used different cache directories
- **Solution**: Unified `CONAN_HOME=/tmp/conan-home-build` for both jobs with `actions/cache@v4`
- **Result**: Test job reuses build artifacts, massive time savings

## Performance Metrics

| Phase | Time (min) | vs Cold Build | vs Previous |
|-------|------------|---------------|-------------|
| Cold Build | 24.47 | - | - |
| Before Optimizations | 10.0 | 59% faster | - |  
| Package Upload | 6.1 | 75% faster | 39% faster |
| GitHub Actions Cache | 2.1 | 91% faster | 66% faster |

## Total Impact
- **91% reduction** in build time compared to cold build
- **79% reduction** compared to unoptimized CI
- From 24+ minutes to ~2 minutes for typical CI runs
- Massive cost savings in CI compute time
- Faster development feedback loops

## Future Optimizations
- Consider preemptive package warming for new dependencies
- Explore distributed caching for even larger projects
- Monitor cache hit rates and adjust retention policies
