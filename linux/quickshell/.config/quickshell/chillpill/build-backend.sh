#!/bin/bash

# build the PillBackend QML plugin (wifi/bluetooth backend) into build/qml/PillBackend
# rerun after a Qt update; the launch command points QML_IMPORT_PATH at build/qml

set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

cmake -S . -B build/cmake -DCMAKE_BUILD_TYPE=Release
cmake --build build/cmake -j"$(nproc)"

mkdir -p build/qml/PillBackend
install -m 644 \
   build/cmake/libPillBackend.so \
   build/cmake/libPillBackendPlugin.so \
   build/cmake/qmldir \
   build/cmake/PillBackend.qmltypes \
     build/qml/PillBackend

echo "PillBackend built into $(pwd)/build/qml/PillBackend"
