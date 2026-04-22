#!/bin/bash

directoryx="$(dirname -- $(readlink -fn -- "$0"; echo x))"
BASEDIR="${directoryx%x}"
STARTDIR=$PWD

SKIP_CONTAINER="false"

for arg in "$@"; do
    if [ "$arg" == "--skip-container" ]; then
        SKIP_CONTAINER="true"
    fi
done

cleanup() {
    cd $STARTDIR
    cd android_compiler/containers
    rm -f *.tar
    rm -f *.tar.gz
}

on_error() {
    cleanup
    echo "An error occurred during the build process. Please check the logs."
    echo "Build failed. Please try again."
    exit 1
}

build_compiler() {
    cd $BASEDIR
    docker build -t android-clang -f Dockerfile .
    if [ $? -ne 0 ]; then
        echo "Error building the Docker image."
        on_error
    fi
    echo "Hexio's Android clang container built successfully."
    cd $STARTDIR
}

save_compiler_container() {
    cd $BASEDIR
    mkdir -p android_compiler/containers
    docker save -o android_compiler/containers/android-clang.tar android-clang
    if [ $? -ne 0 ]; then
        echo "Error saving the Docker image."
        on_error
    fi
    gzip android_compiler/containers/android-clang.tar
    echo "Hexio's Android clang container saved successfully."
    cd $STARTDIR
}

tarball_plugin() {
    cd $BASEDIR
    mkdir -p build
    rm -f build/*
    tar -czf build/android_compiler.tar.gz -C android_compiler .
    echo "Hexio Android compiler plugin tarball created at build/android_compiler.tar.gz"
}

main() {
    if [ "$SKIP_CONTAINER" == "true" ]; then
        echo "[!] Skipping container build."
    else
        build_compiler
    fi
    save_compiler_container
    tarball_plugin
    cleanup
    echo "[!] Hexio Android compiler plugin build completed."
    cd $STARTDIR
}

main
