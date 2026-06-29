#!/usr/bin/env bash

# Exit on error for safety where appropriate
set -e

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Path to the Flutter SDK we installed
CUSTOM_FLUTTER="$HOME/flutter-sdk/bin/flutter"

if [ -f "$CUSTOM_FLUTTER" ]; then
    FLUTTER_BIN="$CUSTOM_FLUTTER"
elif command -v flutter &> /dev/null; then
    FLUTTER_BIN="flutter"
else
    log_error "Flutter is not installed or not in your PATH (checked '$CUSTOM_FLUTTER' and system PATH). Please install Flutter first."
    exit 1
fi

run_web() {
    log_info "Running app on Web (Chrome)..."
    "$FLUTTER_BIN" run -d chrome
}

run_android() {
    log_info "Detecting Android devices/emulators..."
    local target_device="$1"
    
    # Try to auto-detect the first connected Android device if none is passed
    if [ -z "$target_device" ]; then
        target_device=$("$FLUTTER_BIN" devices | grep -i "android" | head -n 1 | awk -F' • ' '{print $2}' | tr -d ' ' || true)
    fi

    if [ -n "$target_device" ]; then
        log_info "Running app on Android device: $target_device"
        "$FLUTTER_BIN" run -d "$target_device"
    else
        log_warning "No active Android devices or emulators found."
        log_info "Attempting to run with standard Android target (will launch default emulator if available)..."
        "$FLUTTER_BIN" run -d android
    fi
}

build_web() {
    log_info "Building Flutter app for Web..."
    "$FLUTTER_BIN" build web
    log_success "Web build complete! Output is in build/web/"
}

build_apk() {
    log_info "Building Flutter APK (Release)..."
    "$FLUTTER_BIN" build apk --release
    log_success "APK build complete! Output is in build/app/outputs/flutter-apk/app-release.apk"
}

show_devices() {
    log_info "Checking available Flutter devices..."
    "$FLUTTER_BIN" devices
}

install_release() {
    log_info "Installing the Release APK to device..."
    local target_device="$2"
    
    # Try to auto-detect the first connected Android device if none is passed
    if [ -z "$target_device" ]; then
        target_device=$("$FLUTTER_BIN" devices | grep -i "android" | head -n 1 | awk -F' • ' '{print $2}' | tr -d ' ' || true)
    fi

    # Build first to ensure release APK is present
    build_apk

    if [ -n "$target_device" ]; then
        log_info "Installing APK to Android device: $target_device"
        "$FLUTTER_BIN" install -d "$target_device"
    else
        log_warning "No active Android devices found. Attempting to install on default target..."
        "$FLUTTER_BIN" install
    fi
}

run_release() {
    log_info "Building and running app in Release mode on Android..."
    local target_device="$2"
    
    # Try to auto-detect the first connected Android device if none is passed
    if [ -z "$target_device" ]; then
        target_device=$("$FLUTTER_BIN" devices | grep -i "android" | head -n 1 | awk -F' • ' '{print $2}' | tr -d ' ' || true)
    fi

    if [ -n "$target_device" ]; then
        log_info "Running in release mode on Android device: $target_device"
        "$FLUTTER_BIN" run --release -d "$target_device"
    else
        log_warning "No active Android devices or emulators found."
        log_info "Attempting to run with standard Android target in release mode..."
        "$FLUTTER_BIN" run --release -d android
    fi
}

show_help() {
    echo "Flutter Run & Build Helper Script"
    echo "================================="
    echo "Usage: ./run.sh [command]"
    echo ""
    echo "Commands:"
    echo "  web             Run app on Web (Chrome)"
    echo "  android         Run app on Android device/emulator"
    echo "  build-web       Build production web files"
    echo "  build-apk       Build release Android APK"
    echo "  install-release Build and Install Release APK to device"
    echo "  run-release     Build and Run App in Release mode on device"
    echo "  devices         List all connected devices"
    echo "  help            Show this help screen"
    echo ""
    echo "If no command is provided, an interactive menu will be shown."
}

# Check argument
CMD=${1:-""}

case "$CMD" in
    web)
        run_web
        ;;
    android)
        run_android "$2"
        ;;
    build-web)
        build_web
        ;;
    build-apk)
        build_apk
        ;;
    install-release)
        install_release "$@"
        ;;
    run-release)
        run_release "$@"
        ;;
    devices)
        show_devices
        ;;
    help|-h|--help)
        show_help
        ;;
    "")
        # Interactive mode
        echo -e "${BLUE}=========================================${NC}"
        echo -e "${BLUE}    Flutter Run/Build Helper Script      ${NC}"
        echo -e "${BLUE}=========================================${NC}"
        echo "1) Run on Web (Chrome)"
        echo "2) Run on Android"
        echo "3) Build for Web"
        echo "4) Build Android APK (Release)"
        echo "5) Build and Install Release APK to device"
        echo "6) Build and Run in Release Mode on device"
        echo "7) List Connected Devices"
        echo "8) Exit"
        echo -n "Choose an option (1-8): "
        read -r choice
        
        case $choice in
            1) run_web ;;
            2) run_android ;;
            3) build_web ;;
            4) build_apk ;;
            5) install_release ;;
            6) run_release ;;
            7) show_devices ;;
            8) log_info "Exiting."; exit 0 ;;
            *) log_error "Invalid option."; exit 1 ;;
        esac
        ;;
    *)
        log_error "Unknown command: $CMD"
        show_help
        exit 1
        ;;
esac
