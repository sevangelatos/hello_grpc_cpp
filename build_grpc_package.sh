#!/bin/bash
set -ex
apt install build-essential autoconf libtool pkg-config libssl-dev protobuf-compiler zlib1g-dev checkinstall

git clone https://github.com/grpc/grpc
cd grpc

# Switch to the version that you prefer to build
git checkout v1.20.1

# Pull in submodules
git submodule update --init

# Install zlib
#cd third_party/zlib
#mkdir -p cmake/build
#cd cmake/build
#cmake -DCMAKE_BUILD_TYPE=Release ../..
#make -j4 install
#cd ../../../..
#rm -rf third_party/zlib

# Install c-ares
cd third_party/cares/cares
mkdir -p cmake/cares
cd cmake/cares
cmake -DCMAKE_BUILD_TYPE=Release ../..
make -j4
checkinstall
cd ../../../../..
rm -rf third_party/cares/cares

# Commented out to use the system protobufs instead
# Install protobuf
#cd third_party/protobuf
#mkdir -p cmake/build
#cd cmake/build
#cmake -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release ..
#make -j4 install
#cd ../../../..
rm -rf third_party/protobuf 


# Install gRPC
mkdir -p cmake/grpc
cd cmake/grpc
cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DgRPC_PROTOBUF_PROVIDER=package -DgRPC_ZLIB_PROVIDER=package -DgRPC_CARES_PROVIDER=package -DgRPC_SSL_PROVIDER=package -DCMAKE_BUILD_TYPE=Release ../..
make -j4
checkinstall
cd ../..



