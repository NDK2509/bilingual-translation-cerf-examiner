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
    # Get list of devices and filter for android/emulator
    devices=$("$FLUTTER_BIN" devices | grep -E "android|emulator" || true)
    if [ -z "$devices" ]; then
        log_warning "No active Android devices or emulators found."
        log_info "Attempting to run with standard Android target (will launch default emulator if available)..."
    else
        log_info "Found the following Android device(s):"
        echo "$devices"
        echo ""
    fi
    log_info "Running app on Android..."
    "$FLUTTER_BIN" run -d android
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

show_help() {
    echo "Flutter Run & Build Helper Script"
    echo "================================="
    echo "Usage: ./run.sh [command]"
    echo ""
    echo "Commands:"
    echo "  web         Run app on Web (Chrome)"
    echo "  android     Run app on Android device/emulator"
    echo "  build-web   Build production web files"
    echo "  build-apk   Build release Android APK"
    echo "  devices     List all connected devices"
    echo "  help        Show this help screen"
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
        run_android
        ;;
    build-web)
        build_web
        ;;
    build-apk)
        build_apk
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
        echo "5) List Connected Devices"
        echo "6) Exit"
        echo -n "Choose an option (1-6): "
        read -r choice
        
        case $choice in
            1) run_web ;;
            2) run_android ;;
            3) build_web ;;
            4) build_apk ;;
            5) show_devices ;;
            6) log_info "Exiting."; exit 0 ;;
            *) log_error "Invalid option."; exit 1 ;;
        esac
        ;;
    *)
        log_error "Unknown command: $CMD"
        show_help
        exit 1
        ;;
esac
