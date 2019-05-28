#!/bin/bash
set -ex

export GRPC_VERSION=1.20.1
export PROTOBUF_VERSION=3.7.0

INVOKED_DIR="$(pwd)"

# Move to the script's dir
cd "$(dirname "$0")"

sudo apt install build-essential autoconf libtool pkg-config libssl-dev zlib1g-dev libc-ares-dev libc-ares2 checkinstall

if [ ! -d grpc ]; then
    git clone https://github.com/grpc/grpc
fi
cd grpc

# Switch to the version that you prefer to build
git checkout -f "v${GRPC_VERSION}"

# Pull in submodules
git submodule update --init

# Use system  zlib
rm -rf third_party/zlib

# Use system c-ares
rm -rf third_party/cares/cares

# Make and install protobuf package
cd third_party/protobuf
mkdir -p cmake/build
cd cmake/build
cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release ..
make -j4
sudo checkinstall \
    --type debian \
    --pkgname protobuf-mrx \
    --pkgversion "${PROTOBUF_VERSION}" \
    --arch amd64 \
    --maintainer "sevangelatos@gmail.com" \
    --requires "zlib1g-dev" \
    --nodoc \
    --exclude . \
    --default   # Accept default answers for the rest
mv *.deb "${INVOKED_DIR}"
cd ../../../..
rm -rf third_party/protobuf 

# apply patches to use system cares
patch -p1 < ../0001-Patch-cares.cmake-to-point-to-system-cares-lib.patch

# Remove any previous build artifacts
sudo rm -rf cmake/grpc
# Install gRPC
mkdir -p cmake/grpc
cd cmake/grpc
cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DgRPC_PROTOBUF_PROVIDER=package -DgRPC_ZLIB_PROVIDER=package -DgRPC_CARES_PROVIDER=package -DgRPC_SSL_PROVIDER=package -DCMAKE_BUILD_TYPE=Release ../..
make -j4
sudo checkinstall \
    --type debian \
    --pkgname grpc-mrx \
    --pkgversion "${GRPC_VERSION}" \
    --arch amd64 \
    --maintainer "sevangelatos@gmail.com" \
    --requires "libssl-dev,protobuf-mrx,libc-ares-dev,zlib1g-dev" \
    --nodoc \
    --exclude . \
    --default   # Accept default answers for the rest
mv *.deb "${INVOKED_DIR}"
cd ../..



