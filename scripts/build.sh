#!/bin/bash
# build.sh - Cross-platform build script for Pulse

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    log_info "Flutter version: $(flutter --version | head -n 1)"
}

# Clean build artifacts
clean_build() {
    log_info "Cleaning build artifacts..."
    flutter clean
    flutter pub get
}

# Run tests
run_tests() {
    log_info "Running tests..."
    flutter test --coverage
    
    if [ $? -eq 0 ]; then
        log_info "All tests passed"
    else
        log_error "Tests failed"
        exit 1
    fi
}

# Analyze code
analyze_code() {
    log_info "Analyzing code..."
    flutter analyze --fatal-infos
    
    if [ $? -eq 0 ]; then
        log_info "Code analysis passed"
    else
        log_error "Code analysis failed"
        exit 1
    fi
}

# Build for specific platform
build_platform() {
    local platform=$1
    local build_type=${2:-release}
    
    log_info "Building for $platform ($build_type)..."
    
    case $platform in
        "android")
            flutter build apk --$build_type
            ;;
        "ios")
            flutter build ios --$build_type --no-codesign
            ;;
        "web")
            flutter build web --$build_type
            ;;
        "linux")
            flutter build linux --$build_type
            ;;
        "windows")
            flutter build windows --$build_type
            ;;
        "macos")
            flutter build macos --$build_type
            ;;
        *)
            log_error "Unknown platform: $platform"
            exit 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log_info "Build successful for $platform"
    else
        log_error "Build failed for $platform"
        exit 1
    fi
}

# Deploy to Firebase
deploy_firebase() {
    log_info "Deploying to Firebase..."
    
    if ! command -v firebase &> /dev/null; then
        log_error "Firebase CLI is not installed"
        exit 1
    fi
    
    firebase deploy --only hosting
    
    if [ $? -eq 0 ]; then
        log_info "Firebase deployment successful"
    else
        log_error "Firebase deployment failed"
        exit 1
    fi
}

# Main function
main() {
    local platform=${1:-all}
    local build_type=${2:-release}
    
    log_info "Starting Pulse build process..."
    
    check_flutter
    clean_build
    run_tests
    analyze_code
    
    if [ "$platform" = "all" ]; then
        build_platform "web" $build_type
        build_platform "android" $build_type
        build_platform "ios" $build_type
        build_platform "linux" $build_type
        build_platform "windows" $build_type
        build_platform "macos" $build_type
    else
        build_platform $platform $build_type
    fi
    
    if [ "$platform" = "web" ] || [ "$platform" = "all" ]; then
        deploy_firebase
    fi
    
    log_info "Build process completed successfully!"
}

# Run main function with all arguments
main "$@"
