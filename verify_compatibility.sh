#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status
set -o pipefail # Exit if any command in a pipeline fails

# ------------------------------------------------------------------------------
# 1. Configuration
# ------------------------------------------------------------------------------

# Define paths for Xcode versions
XCODE_26_PATH="/Applications/Xcode.app"
XCODE_16_PATH="/Applications/Xcode16.app"

# Project Paths
STATIC_LIB_PROJECT_DIR="StaticLibraryProject"
APP_PROJECT_DIR="AppProject"
DESTINATION_LIB_PATH="AppProject/AppProject/libStaticLibraryProject.a"
DESTINATION_SWIFTMODULE_PATH="AppProject/StaticLibraryProject.swiftmodule"

# Temporary build directory
BUILD_OUTPUT_DIR="$(pwd)/BuildArtifacts"

CONFIGURATION="Release"

# Uncomment the following line can make the static library work for Xcode 16
# STATIC_LIB_EXTRA_FLAGS='ENABLE_TESTABILITY=NO SWIFT_COMPILATION_MODE=wholemodule SWIFT_OPTIMIZATION_LEVEL=-O'

# ------------------------------------------------------------------------------
# 2. Switch to Xcode 26
# ------------------------------------------------------------------------------

echo "👉 [Step 1] Switching to Xcode 26 ($XCODE_26_PATH)..."

if [ ! -d "$XCODE_26_PATH" ]; then
    echo "Error: Xcode 26 not found at $XCODE_26_PATH"
    exit 1
fi

export DEVELOPER_DIR="$XCODE_26_PATH/Contents/Developer"
echo "Active DEVELOPER_DIR: $DEVELOPER_DIR"
echo "Current Xcode version:"
xcodebuild -version
echo ""

# ------------------------------------------------------------------------------
# 3. Compile StaticLibraryProject with Xcode 26
# ------------------------------------------------------------------------------

echo "👉 [Step 2] Building StaticLibraryProject with Xcode 26..."

# Clean previous build artifacts
rm -rf "$BUILD_OUTPUT_DIR"

# Build the static library
xcodebuild clean build \
    -project "$STATIC_LIB_PROJECT_DIR/StaticLibraryProject.xcodeproj" \
    -scheme "StaticLibraryProject" \
    -configuration $CONFIGURATION \
    -sdk iphoneos \
    -destination "generic/platform=iOS" \
    -quiet \
    SYMROOT="$BUILD_OUTPUT_DIR" \
    ${STATIC_LIB_EXTRA_FLAGS:-} \
    | grep -A 5 "(FAILURE|error:)" || echo "Build output suppressed (success expected)"

# Check if the static library was created
COMPILED_BUILD_PATH="$BUILD_OUTPUT_DIR/$CONFIGURATION-iphoneos"
COMPILED_LIB_PATH="$COMPILED_BUILD_PATH/libStaticLibraryProject.a"
COMPILED_SWIFTMODULE_PATH="$COMPILED_BUILD_PATH/StaticLibraryProject.swiftmodule"

if [ ! -f "$COMPILED_LIB_PATH" ]; then
    echo "Error: Static library not found at $COMPILED_BUILD_PATH"
    exit 1
fi
if [ ! -d "$COMPILED_SWIFTMODULE_PATH" ]; then
    echo "Error: Swiftmodule not found at $COMPILED_SWIFTMODULE_PATH"
    exit 1
fi

echo "✅ Static library built successfully."
echo ""

# ------------------------------------------------------------------------------
# 4. Inspect static library for undefined symbols
# ------------------------------------------------------------------------------

echo "👉 [Step 3] Inspecting static library for undefined symbols..."
echo "Checking for _swift_coroFrameAlloc symbol..."
nm "$COMPILED_LIB_PATH" | grep "_swift_coroFrameAlloc" || echo "✅ Symbol not found."
echo ""

# ------------------------------------------------------------------------------
# 5. Copy .a file to AppProject
# ------------------------------------------------------------------------------

echo "👉 [Step 4] Copying .a and swiftmodule file to AppProject..."

rm -rf "$DESTINATION_LIB_PATH"
cp "$COMPILED_LIB_PATH" "$DESTINATION_LIB_PATH"
rm -rf "$DESTINATION_SWIFTMODULE_PATH"
cp -r "$COMPILED_SWIFTMODULE_PATH" "$DESTINATION_SWIFTMODULE_PATH"

if [ -f "$DESTINATION_LIB_PATH" ] && [ -d "$DESTINATION_SWIFTMODULE_PATH" ]; then
    echo "✅ Files copied successfully."
    echo ""
else
    echo "Error: Failed to copy files."
    exit 1
fi

# ------------------------------------------------------------------------------
# 6. Switch to Xcode 16
# ------------------------------------------------------------------------------

echo "👉 [Step 5] Switching to Xcode 16 ($XCODE_16_PATH)..."

if [ ! -d "$XCODE_16_PATH" ]; then
    echo "Error: Xcode 16 not found at $XCODE_16_PATH"
    exit 1
fi

export DEVELOPER_DIR="$XCODE_16_PATH/Contents/Developer"
echo "Active DEVELOPER_DIR: $DEVELOPER_DIR"
echo "Current Xcode version:"
xcodebuild -version
echo ""

# ------------------------------------------------------------------------------
# 7. Compile AppProject with Xcode 16
# ------------------------------------------------------------------------------

echo "👉 [Step 6] Building AppProject with Xcode 16..."

# Build the application project linking the previously built static library
xcodebuild clean build \
    -project "$APP_PROJECT_DIR/AppProject.xcodeproj" \
    -scheme "AppProject" \
    -configuration $CONFIGURATION \
    -sdk iphoneos \
    -destination "generic/platform=iOS" \
    -quiet \
    SYMROOT="$BUILD_OUTPUT_DIR/AppBuild"

echo "✅ VERIFICATION COMPLETED"
echo ""