#!/bin/bash

set -e

if [ -z $1 ]; then
    echo "Please specify wasmedge path"
else
    WASMEDGE=$1
    WASI_NN_DIR=$(dirname "$0" | xargs dirname)
    WASI_NN_DIR=$(realpath $WASI_NN_DIR)
    WASMEDGE=$(realpath $WASMEDGE)
    source /opt/intel/openvino_2021/bin/setupvars.sh

    pushd $WASI_NN_DIR/rust/
    mkdir -p $WASI_NN_DIR/rust/mobilenet-base/build
    RUST_BUILD_DIR=$(realpath $WASI_NN_DIR/rust/mobilenet-base/build/)
    bash ${WASI_NN_DIR}/scripts/download_mobilenet.sh ${RUST_BUILD_DIR}
    pushd mobilenet-base
    cargo build --release --target=wasm32-wasi
    cp target/wasm32-wasi/release/mobilenet-base-example.wasm $RUST_BUILD_DIR
    pushd build
    # Manually run .wasm
    echo "Running example with WasmEdge ${WASMEDGE}"
    $WASMEDGE --dir fixture:$RUST_BUILD_DIR --dir .:. mobilenet-base-example.wasm "fixture/mobilenet.xml" "fixture/mobilenet.bin" "fixture/tensor-1x224x224x3-f32.bgr"
fi
