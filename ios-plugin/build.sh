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
    cd ios_compiler/containers
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
    #just build the Dockerfile
    docker build -t ios-clang -f Dockerfile .
    if [ $? -ne 0 ]; then
        echo "Error building the Docker image."
        on_error
    fi
    echo "Hexio's iOS clang container built successfully."
    cd $STARTDIR
}

save_compiler_container() {
    cd $BASEDIR
    docker save -o ios_compiler/containers/ios-clang.tar ios-clang
    if [ $? -ne 0 ]; then
        echo "Error saving the Docker image."
        on_error
    fi
    gzip ios_compiler/containers/ios-clang.tar
    echo "Hexio's iOS clang container saved successfully."
    cd $STARTDIR
}

tarball_plugin() {
    #We need to tarball ios_compiler to ios_compiler.tar.gz
    cd $BASEDIR
    mkdir -p build
    rm -f build/*
    #Tarball $BASEDIR/ios_compiler directory to build/ios_compiler.tar.gz
    tar -czf build/ios_compiler.tar.gz -C ios_compiler .
    echo "Hexio iOS compiler plugin tarball created at build/ios_compiler.tar.gz"
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
    echo "[!] Hexio iOS compiler plugin build completed."
    cd $STARTDIR
}

main