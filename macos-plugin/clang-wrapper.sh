#!/usr/bin/env bash

# This file is used as a entrypoint wrapper for either arm64 or x86_64 darwin clang++ compilers
# # Usage: ./clang-wrapper.sh --arch=arm64|x86_64 [clang++ args...]
# The file is handled within hexio using the compiler scripts (bash wrappers around Docker) allowing them to use 1 container for both arches
# This reduces the net size of the plugin while still allowing us to compile for both targets

ARCH=""
ARGS=()

# Parse --arch=ARCH and preserve all other arguments
for arg in "$@"; do
    if [[ "$arg" == --arch=* ]]; then
        ARCH="${arg#--arch=}"
    else
        ARGS+=("$arg")
    fi
done

# Validate arch
case "$ARCH" in
    arm64)
        COMPILER="arm64-apple-darwin24.5-clang++"
        ;;
    x86_64)
        COMPILER="x86_64-apple-darwin24.5-clang++"
        ;;
    "")
        echo "Usage: $0 --arch=arm64|x86_64 [clang++ args...]" >&2
        exit 1
        ;;
    *)
        echo "Unknown architecture: $ARCH" >&2
        exit 1
        ;;
esac

# Run the compiler with remaining args
exec "$COMPILER" "${ARGS[@]}"