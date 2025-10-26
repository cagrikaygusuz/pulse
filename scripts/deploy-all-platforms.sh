#!/bin/bash
# deploy-all-platforms.sh

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

echo "Deploying Pulse Timer version $VERSION"

# Update version in pubspec.yaml
sed -i "s/version: .*/version: $VERSION/" pubspec.yaml

# Commit version change
git add pubspec.yaml
git commit -m "Release version $VERSION"
git tag "v$VERSION"
git push origin main
git push origin "v$VERSION"

# Create GitHub release
gh release create "v$VERSION" \
  --title "Pulse Timer $VERSION" \
  --notes "Release notes for version $VERSION" \
  --latest

echo "Release $VERSION created successfully!"
