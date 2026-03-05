#!/usr/bin/env bash
# Bumps the version in pubspec.yaml and outputs the new version.
# Usage: ./scripts/bump_version.sh [major|minor|patch]
# Default: patch

set -euo pipefail

BUMP_TYPE="${1:-patch}"
PUBSPEC="pubspec.yaml"

# Extract current version line (e.g., "version: 1.2.3+4")
CURRENT=$(grep -E '^version:' "$PUBSPEC" | head -1 | awk '{print $2}')

# Split into version name and build number
VERSION_NAME="${CURRENT%%+*}"
BUILD_NUMBER="${CURRENT#*+}"

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_NAME"

case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Unknown bump type: $BUMP_TYPE (use major, minor, or patch)" >&2
    exit 1
    ;;
esac

NEW_BUILD=$((BUILD_NUMBER + 1))
NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}+${NEW_BUILD}"

# Replace in pubspec.yaml
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"
else
  sed -i "s/^version: .*/version: ${NEW_VERSION}/" "$PUBSPEC"
fi

echo "$NEW_VERSION"
