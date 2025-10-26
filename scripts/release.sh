#!/bin/bash
# release.sh - Release management script for Pulse

set -e

# Configuration
REPO_OWNER="cagrikaygusuz"
REPO_NAME="pulse"
CURRENT_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')

# Functions
log_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# Bump version
bump_version() {
    local version_type=$1
    
    log_info "Bumping version ($version_type)..."
    
    case $version_type in
        "major")
            new_version=$(echo $CURRENT_VERSION | awk -F. '{print $1+1".0.0"}')
            ;;
        "minor")
            new_version=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2+1".0"}')
            ;;
        "patch")
            new_version=$(echo $CURRENT_VERSION | awk -F. '{print $1"."$2"."$3+1}')
            ;;
        *)
            log_error "Invalid version type: $version_type"
            exit 1
            ;;
    esac
    
    # Update pubspec.yaml
    sed -i "s/version: $CURRENT_VERSION/version: $new_version/" pubspec.yaml
    
    log_info "Version bumped from $CURRENT_VERSION to $new_version"
    echo $new_version
}

# Generate changelog
generate_changelog() {
    local version=$1
    
    log_info "Generating changelog for version $version..."
    
    # Get commits since last tag
    local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    local commits=""
    
    if [ -n "$last_tag" ]; then
        commits=$(git log --oneline $last_tag..HEAD)
    else
        commits=$(git log --oneline)
    fi
    
    # Create changelog entry
    cat > CHANGELOG.md << EOF
# Changelog

## [$version] - $(date +%Y-%m-%d)

### Added
- New features and improvements

### Changed
- Changes to existing functionality

### Fixed
- Bug fixes

### Commits
$commits

EOF
    
    log_info "Changelog generated"
}

# Create release
create_release() {
    local version=$1
    
    log_info "Creating release $version..."
    
    # Commit version change
    git add pubspec.yaml CHANGELOG.md
    git commit -m "Release version $version"
    git tag -a "v$version" -m "Release version $version"
    
    # Push changes
    git push origin main
    git push origin "v$version"
    
    log_info "Release $version created and pushed"
}

# Main function
main() {
    local version_type=${1:-patch}
    
    log_info "Starting release process..."
    
    # Check if working directory is clean
    if ! git diff-index --quiet HEAD --; then
        log_error "Working directory is not clean. Please commit or stash changes."
        exit 1
    fi
    
    # Bump version
    local new_version=$(bump_version $version_type)
    
    # Generate changelog
    generate_changelog $new_version
    
    # Create release
    create_release $new_version
    
    log_info "Release process completed successfully!"
}

# Run main function
main "$@"
