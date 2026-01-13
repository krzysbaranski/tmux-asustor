#!/bin/bash
set -e

# Build script for tmux and dependencies for ASUSTOR NAS
# This script downloads, compiles, and packages tmux

TMUX_VERSION="3.6a"
LIBEVENT_VERSION="2.1.12"
NCURSES_VERSION="6.5"

# Build configuration
# PREFIX: Path used during build/staging (can be any path for development)
# INSTALL_PREFIX: Actual runtime path where ASUSTOR will install the package
PREFIX="/usr/local/tmux"
BUILD_DIR="$(pwd)/build"
STAGING_DIR="$(pwd)/staging"
PACKAGE_DIR="$(pwd)/apkg"

# ASUSTOR installs packages to /usr/local/AppCentral/<package_name>
# We need to set RPATH to ensure binaries use the packaged libraries
INSTALL_PREFIX="/usr/local/AppCentral/tmux"

# Create build and staging directories
mkdir -p "$BUILD_DIR"
mkdir -p "$STAGING_DIR"
cd "$BUILD_DIR"

echo "================================================"
echo "Building tmux ${TMUX_VERSION} for ASUSTOR NAS"
echo "================================================"

# Function to download and extract
download_and_extract() {
    local name=$1
    local version=$2
    local url=$3
    local ext=$4
    local dirname=$5
    
    echo "Downloading ${name} ${version}..."
    wget -q "${url}" -O "${name}-${version}.${ext}"
    echo "Extracting ${name} ${version}..."
    if [ "$ext" = "tar.gz" ]; then
        tar xzf "${name}-${version}.${ext}"
    elif [ "$ext" = "tar.bz2" ]; then
        tar xjf "${name}-${version}.${ext}"
    fi
}

# Download sources
echo "Step 1: Downloading source packages..."

# Download ncurses
download_and_extract "ncurses" "$NCURSES_VERSION" \
    "https://ftp.gnu.org/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz" "tar.gz"

# Download libevent
download_and_extract "libevent" "$LIBEVENT_VERSION" \
    "https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/libevent-${LIBEVENT_VERSION}-stable.tar.gz" "tar.gz"

# Download tmux
download_and_extract "tmux" "$TMUX_VERSION" \
    "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" "tar.gz"

# Build ncurses (required by tmux for terminal handling)
echo ""
echo "Step 2: Building ncurses..."
cd "ncurses-${NCURSES_VERSION}"
CFLAGS="-fPIC" LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure \
    --prefix="$PREFIX" \
    --with-shared \
    --without-debug \
    --without-ada \
    --without-cxx-binding \
    --enable-widec \
    --enable-pc-files \
    --with-pkg-config-libdir="${PREFIX}/lib/pkgconfig"
make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Create symlinks for ncurses (some programs look for non-wide versions)
echo "Creating ncurses compatibility symlinks..."
cd "${STAGING_DIR}${PREFIX}/lib"
for lib in ncurses form panel menu; do
    if [ -f "lib${lib}w.so" ]; then
        ln -sf "lib${lib}w.so" "lib${lib}.so"
    fi
    if [ -f "lib${lib}w.a" ]; then
        ln -sf "lib${lib}w.a" "lib${lib}.a"
    fi
done
# Create ncurses -> ncursesw include symlink
cd "${STAGING_DIR}${PREFIX}/include"
if [ -d "ncursesw" ] && [ ! -e "ncurses" ]; then
    ln -sf ncursesw ncurses
fi
cd "$BUILD_DIR"

# Set up environment to use staged dependencies
export PKG_CONFIG_PATH="${STAGING_DIR}${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export PATH="${STAGING_DIR}${PREFIX}/bin:$PATH"
export LD_LIBRARY_PATH="${STAGING_DIR}${PREFIX}/lib:$LD_LIBRARY_PATH"
export CPPFLAGS="-I${STAGING_DIR}${PREFIX}/include -I${STAGING_DIR}${PREFIX}/include/ncursesw"
export LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib"

# Build libevent (required by tmux)
echo ""
echo "Step 3: Building libevent..."
cd "libevent-${LIBEVENT_VERSION}-stable"
CFLAGS="-fPIC" LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
./configure \
    --prefix="$PREFIX" \
    --disable-openssl \
    --disable-samples
make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Update pkg-config path after libevent install
export PKG_CONFIG_PATH="${STAGING_DIR}${PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"

# Build tmux
echo ""
echo "Step 4: Building tmux..."
cd "tmux-${TMUX_VERSION}"

# Configure tmux with our staged dependencies
CFLAGS="-I${STAGING_DIR}${PREFIX}/include -I${STAGING_DIR}${PREFIX}/include/ncursesw" \
LDFLAGS="-L${STAGING_DIR}${PREFIX}/lib -Wl,-rpath,${INSTALL_PREFIX}/lib" \
LIBEVENT_CFLAGS="-I${STAGING_DIR}${PREFIX}/include" \
LIBEVENT_LIBS="-L${STAGING_DIR}${PREFIX}/lib -levent" \
LIBNCURSES_CFLAGS="-I${STAGING_DIR}${PREFIX}/include/ncursesw" \
LIBNCURSES_LIBS="-L${STAGING_DIR}${PREFIX}/lib -lncursesw" \
./configure \
    --prefix="$PREFIX" \
    --enable-static

make -j$(nproc)
make install DESTDIR="${STAGING_DIR}"
cd ..

# Note: Package preparation is done by package.sh after build
cd ..

echo ""
echo "================================================"
echo "Build completed successfully!"
echo "================================================"
echo ""

# Run the packaging script
if [ -f "$(pwd)/package.sh" ]; then
    echo "Running package.sh to prepare ASUSTOR package..."
    "$(pwd)/package.sh"
else
    echo "Warning: package.sh not found, skipping package preparation"
fi

echo ""

# Run the validation script
if [ -f "$(pwd)/validate-package.sh" ]; then
    echo "Running validate-package.sh to validate package contents..."
    "$(pwd)/validate-package.sh" || echo "Note: Validation completed with warnings or errors (see above)"
else
    echo "Warning: validate-package.sh not found, skipping validation"
fi
