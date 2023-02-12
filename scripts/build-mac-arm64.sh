#!/bin/bash

set -e

SCRIPTS_DIR="$( dirname -- "$0"; )"
BASE_DIR="$SCRIPTS_DIR/.."
SOURCES_DIR="$BASE_DIR/sources"
ARTIFACTS_DIR="$BASE_DIR/artifacts"

TARGET_DIR="$ARTIFACTS_DIR/mac-arm64"

pushd "$SOURCES_DIR/libusb"
./autogen.sh
CXXFLAGS="-mmacosx-version-min=11.0" CFLAGS="-mmacosx-version-min=11.0" ./configure
make
popd

pushd "$SOURCES_DIR/libjpeg-turbo"
rm -rf build
mkdir build
pushd "build"
cmake .. -G"Unix Makefiles" -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0
cmake --build .
popd
popd

pushd "$SOURCES_DIR/sane-backends"
./autogen.sh
LDFLAGS="-L$( realpath "../libjpeg-turbo/build"; ) -L$( realpath "../libusb/libusb/.libs"; )" \
CPPFLAGS="-I$( realpath "../libjpeg-turbo"; ) -I$( realpath "../libjpeg-turbo/build"; ) -I$( realpath "../libusb/libusb"; )" \
CXXFLAGS="-mmacosx-version-min=11.0" CFLAGS="-mmacosx-version-min=11.0" \
./configure
make
popd

cp "$SOURCES_DIR/libusb/libusb/.libs/libusb-1.0.0.dylib" "$TARGET_DIR/libusb-1.0.0.dylib"

cp "$SOURCES_DIR/libjpeg-turbo/build/libjpeg.62.dylib" "$TARGET_DIR/libjpeg.62.dylib"

cp "$SOURCES_DIR/sane-backends/backend/.libs/libsane.1.dylib" "$TARGET_DIR/libsane.1.dylib"
rm -rf "$TARGET_DIR/sane"
mkdir "$TARGET_DIR/sane"
for f in $SOURCES_DIR/sane-backends/backend/.libs/libsane-*.so; do
  [[ $f != *.1.so ]] && continue
  cp "$f" "$TARGET_DIR/sane/"
done
