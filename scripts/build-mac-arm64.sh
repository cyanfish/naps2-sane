#!/bin/bash

set -e

SCRIPTS_DIR="$( dirname -- "$0"; )"
BASE_DIR="$SCRIPTS_DIR/.."
SOURCES_DIR="$BASE_DIR/sources"
ARTIFACTS_DIR="$BASE_DIR/artifacts"

TARGET_DIR="$ARTIFACTS_DIR/mac-arm64"

pushd "$SOURCES_DIR/libusb"
./autogen.sh
./configure
make
popd

pushd "$SOURCES_DIR/libjpeg-turbo"
cmake cmake -G"Unix Makefiles" .
make
popd

# TODO: Try to get ldflags to work with compiled sources
export LDFLAGS="-L/opt/local/lib"
pushd "$SOURCES_DIR/sane-backends"
./autogen.sh
./configure
make
popd

cp "$SOURCES_DIR/libusb/libusb/.libs/libusb-1.0.0.dylib" "$TARGET_DIR/libusb.dylib"

cp "$SOURCES_DIR/libjpeg-turbo/libjpeg.dylib" "$TARGET_DIR/libjpeg.dylib"

cp "$SOURCES_DIR/sane-backends/backend/.libs/libsane.1.dylib" "$TARGET_DIR/libsane.dylib"
rm -rf "$TARGET_DIR/sane"
mkdir "$TARGET_DIR/sane"
for f in $SOURCES_DIR/sane-backends/backend/.libs/libsane-*.so; do
  [[ $f = *.1.so ]] && continue
  cp "$f" "$TARGET_DIR/sane/"
done
