#!/bin/bash

set -e

SCRIPTS_DIR="$( dirname -- "$0"; )"
BASE_DIR="$SCRIPTS_DIR/.."
SOURCES_DIR="$BASE_DIR/sources"
ARTIFACTS_DIR="$BASE_DIR/artifacts"

TARGET_DIR="$ARTIFACTS_DIR/mac-arm64"

pushd "$SOURCES_DIR/libusb"
./autogen.sh
CXXFLAGS="-mmacosx-version-min=10.15" CFLAGS="-mmacosx-version-min=10.15" ./configure
make
popd

pushd "$SOURCES_DIR/libjpeg-turbo"
rm -rf build
mkdir build
pushd "build"
cmake .. -G"Unix Makefiles" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15
cmake --build .
popd
popd

pushd "$SOURCES_DIR/sane-backends"
./autogen.sh
LDFLAGS="-L$( realpath "../libjpeg-turbo/build"; ) -L$( realpath "../libusb/libusb/.libs"; )" \
CPPFLAGS="-I$( realpath "../libjpeg-turbo"; ) -I$( realpath "../libjpeg-turbo/build"; ) -I$( realpath "../libusb/libusb"; )" \
CXXFLAGS="-mmacosx-version-min=10.15" CFLAGS="-mmacosx-version-min=10.15" \
./configure
make
popd

cp "$SOURCES_DIR/libusb/libusb/.libs/libusb-1.0.0.dylib" "$TARGET_DIR/libusb.dylib"

cp "$SOURCES_DIR/libjpeg-turbo/build/libjpeg.dylib" "$TARGET_DIR/libjpeg.dylib"

cp "$SOURCES_DIR/sane-backends/backend/.libs/libsane.1.dylib" "$TARGET_DIR/libsane.dylib"
rm -rf "$TARGET_DIR/sane"
mkdir "$TARGET_DIR/sane"
for f in $SOURCES_DIR/sane-backends/backend/.libs/libsane-*.so; do
  [[ $f = *.1.so ]] && continue
  cp "$f" "$TARGET_DIR/sane/"
done

cp "$SOURCES_DIR/libjpeg-turbo/LICENSE.md" "$TARGET_DIR/../libjpeg-turbo-license.md"
cp "$SOURCES_DIR/libusb/COPYING" "$TARGET_DIR/../libusb-license.txt"
cp "$SOURCES_DIR/libusb/AUTHORS" "$TARGET_DIR/../libusb-authors.txt"
cp "$SOURCES_DIR/sane-backends/AUTHORS" "$TARGET_DIR/../sane-backends-authors.txt"
cp "$SOURCES_DIR/sane-backends/LICENSE" "$TARGET_DIR/../sane-backends-license.txt"