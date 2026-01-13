#!/bin/bash
set -e

# Package script for tmux ASUSTOR APK
# This script prepares the package structure by copying files from staging

STAGING_DIR="$(pwd)/staging"
PACKAGE_DIR="$(pwd)/apkg"
PREFIX="/usr/local/tmux"
INSTALL_PREFIX="/usr/local/AppCentral/tmux"

echo "================================================"
echo "Packaging tmux for ASUSTOR"
echo "================================================"

# Check if staging directory exists
if [ ! -d "${STAGING_DIR}${PREFIX}" ]; then
    echo "Error: Staging directory not found at ${STAGING_DIR}${PREFIX}"
    echo "Please run build.sh first to build tmux"
    exit 1
fi

# Clean up old package structure (keep CONTROL)
echo "Step 1: Cleaning up old package structure..."
find "${PACKAGE_DIR}" -mindepth 1 -maxdepth 1 -type d ! -name "CONTROL" -exec rm -rf {} \; 2>/dev/null || true

# Copy everything from staging to package at root level
echo "Step 2: Copying files from staging to package..."
cp -a "${STAGING_DIR}${PREFIX}/"* "${PACKAGE_DIR}/" 2>/dev/null || true

# Create wrapper script for tmux to set up environment
echo "Step 3: Creating tmux wrapper script..."
mv "${PACKAGE_DIR}/bin/tmux" "${PACKAGE_DIR}/bin/tmux.bin"
cat > "${PACKAGE_DIR}/bin/tmux" << 'WRAPPER'
#!/bin/sh
# Wrapper script for tmux to set up environment variables

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_DIR="$(dirname "$SCRIPT_DIR")"

# Set TERMINFO to use the bundled terminal database
export TERMINFO="${PKG_DIR}/share/terminfo"

# Ensure our libraries are found
export LD_LIBRARY_PATH="${PKG_DIR}/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Execute the real tmux binary
exec "${SCRIPT_DIR}/tmux.bin" "$@"
WRAPPER
chmod +x "${PACKAGE_DIR}/bin/tmux"

echo ""
echo "================================================"
echo "Package preparation completed successfully!"
echo "================================================"
echo ""
echo "Package structure:"
echo "  bin/: $(find "${PACKAGE_DIR}/bin" \( -type f -o -type l \) 2>/dev/null | wc -l) files"
echo "  lib/: $(find "${PACKAGE_DIR}/lib" \( -type f -o -type l \) 2>/dev/null | wc -l) files"
echo "  share/: $(find "${PACKAGE_DIR}/share" \( -type f -o -type l \) 2>/dev/null | wc -l) files"
