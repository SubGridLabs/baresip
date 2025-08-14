#!/bin/bash

# Script to trigger GitHub Action build with current diff
# Usage: ./scripts/send-diff-build.sh [preset] [base-branch]

set -euo pipefail

PRESET="${1:-default}"
BASE_BRANCH="${2:-conan-integration}"
REPO_OWNER="${GITHUB_REPO_OWNER:-$(git config --get remote.origin.url | sed -n 's/.*github\.com[:/]\([^/]*\)\/.*/\1/p')}"
REPO_NAME="${GITHUB_REPO_NAME:-$(git config --get remote.origin.url | sed -n 's/.*\/\([^/]*\)\.git.*/\1/p')}"

echo "=== Baresip Diff Build Trigger ==="
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo "Base branch: $BASE_BRANCH"
echo "Build preset: $PRESET"
echo

# Check if we have changes
if ! git diff --quiet; then
    echo "✓ Uncommitted changes detected"
elif ! git diff --quiet HEAD~1; then
    echo "✓ Using last commit changes"
    BASE_BRANCH="HEAD~1"
else
    echo "❌ No changes detected. Make some changes or specify a different base."
    exit 1
fi

# Generate diff
echo "Generating diff..."
DIFF_CONTENT=$(git diff $BASE_BRANCH)

if [ -z "$DIFF_CONTENT" ]; then
    echo "❌ No diff content generated"
    exit 1
fi

echo "📝 Diff preview (first 20 lines):"
echo "$DIFF_CONTENT" | head -20
echo "..."
echo

# Check for GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is required but not installed."
    echo "   Install it from: https://cli.github.com/"
    echo
    echo "📋 Manual trigger instructions:"
    echo "1. Go to: https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/diff-build.yml"
    echo "2. Click 'Run workflow'"
    echo "3. Paste the following diff:"
    echo "----------------------------------------"
    echo "$DIFF_CONTENT"
    echo "----------------------------------------"
    exit 1
fi

# Check GitHub authentication
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI is not authenticated."
    echo "   Run: gh auth login"
    exit 1
fi

# Escape the diff content for JSON
ESCAPED_DIFF=$(echo "$DIFF_CONTENT" | jq -Rs .)

# Trigger the workflow
echo "🚀 Triggering GitHub Action build..."
gh workflow run diff-build.yml \
    --repo "$REPO_OWNER/$REPO_NAME" \
    --field "diff_content=$DIFF_CONTENT" \
    --field "build_preset=$PRESET" \
    --field "target_branch=$BASE_BRANCH"

echo "✅ Build triggered successfully!"
echo "🔗 Check status at: https://github.com/$REPO_OWNER/$REPO_NAME/actions"

# Wait a moment and try to get the run URL
sleep 3
echo
echo "📊 Recent workflow runs:"
gh run list --repo "$REPO_OWNER/$REPO_NAME" --workflow=diff-build.yml --limit=3
