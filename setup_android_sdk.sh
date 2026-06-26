#!/usr/bin/env bash
set -e

# Setup colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}[INFO] Checking Java...${NC}"
if ! command -v java &> /dev/null; then
    echo -e "${YELLOW}[WARNING] Java (JDK) is not installed.${NC}"
    echo -e "Please install Java 17 by running the following in your terminal:"
    echo -e "  ${GREEN}sudo apt update && sudo apt install -y openjdk-17-jdk-headless${NC}"
    echo -e "Once installed, please rerun this script."
    exit 1
fi

SDK_DIR="$HOME/Android/Sdk"
mkdir -p "$SDK_DIR"

echo -e "${BLUE}[INFO] Creating Sdk structure...${NC}"
mkdir -p "$SDK_DIR/cmdline-tools"

# Download command line tools
CMDLINE_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
ZIP_PATH="/tmp/cmdline-tools.zip"

echo -e "${BLUE}[INFO] Downloading Command Line Tools...${NC}"
curl -L -o "$ZIP_PATH" "$CMDLINE_URL"

echo -e "${BLUE}[INFO] Unzipping to Sdk directory...${NC}"
# Extract to a temp dir first because of the nesting in the zip
TEMP_EXTRACT="/tmp/cmdline-extract"
rm -rf "$TEMP_EXTRACT"
mkdir -p "$TEMP_EXTRACT"
unzip -q "$ZIP_PATH" -d "$TEMP_EXTRACT"

# Clean existing latest if any
rm -rf "$SDK_DIR/cmdline-tools/latest"
mkdir -p "$SDK_DIR/cmdline-tools/latest"

# Move the contents of cmdline-tools inside the zip to latest
mv "$TEMP_EXTRACT/cmdline-tools/"* "$SDK_DIR/cmdline-tools/latest/"

# Cleanup temp files
rm -rf "$TEMP_EXTRACT" "$ZIP_PATH"

echo -e "${BLUE}[INFO] Installing Android SDK platform-tools, build-tools, and platforms...${NC}"
"$SDK_DIR/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK_DIR" "platform-tools" "build-tools;34.0.0" "platforms;android-34"

echo -e "${BLUE}[INFO] Configuring Flutter Android SDK path...${NC}"
"$HOME/flutter-sdk/bin/flutter" config --android-sdk "$SDK_DIR"

echo -e "${GREEN}[SUCCESS] Android SDK installation completed successfully!${NC}"
echo -e "Please run the following command to accept Android licenses:"
echo -e "  ${GREEN}$HOME/flutter-sdk/bin/flutter doctor --android-licenses${NC}"
