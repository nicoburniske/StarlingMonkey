#!/bin/bash

if [ -d "cmake-build-debug" ]; then
    rm -rf cmake-build-debug
fi

echo "Building dev config"
cmake -S . -B cmake-build-debug -DCMAKE_BUILD_TYPE=Debug

echo "Building test cases"
# cmake --build cmake-build-debug --parallel 8 --target test-cases
cmake --build cmake-build-debug --parallel 8 --target smoke-test

echo "Running test case"
# CTEST_OUTPUT_ON_FAILURE=1 make -C cmake-build-debug test

cd cmake-build-debug
wasmtime_log="wasmtime.log"

wasmtime serve -S common smoke-test.wasm > "$wasmtime_log" 2>&1 &
wasmtime_pid="$!"

# Wait for a short duration to allow wasmtime to start
sleep 1

# Check if wasmtime process is running
if ! ps -p ${wasmtime_pid} > /dev/null; then
  echo "Failed to start wasmtime serve"
  exit 1
fi

function cleanup {
   kill -9 ${wasmtime_pid}
}

trap cleanup EXIT

until cat $wasmtime_log | grep -m 1 "Serving HTTP" >/dev/null || ! ps -p ${wasmtime_pid} >/dev/null; do : ; done

if ! ps -p ${wasmtime_pid} >/dev/null; then
   echo "Wasmtime exited early"
   >&2 cat "$wasmtime_log"
   exit 1
fi

status_code=$(curl --silent http://localhost:8080)

if [ ! "$status_code" = "200" ]; then
   echo "Bad status code $status_code"
   >&2 cat "$wasmtime_log"
   exit 1
fi