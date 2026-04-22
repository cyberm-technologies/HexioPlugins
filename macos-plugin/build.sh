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
    cd macos_compiler/containers
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
    docker build -t darwin-clang -f Dockerfile .
    if [ $? -ne 0 ]; then
        echo "Error building the Docker image."
        on_error
    fi
    echo "Hexio's macOS clang container built successfully."
    cd $STARTDIR
}

save_compiler_container() {
    cd $BASEDIR
    docker save -o macos_compiler/containers/darwin-clang.tar darwin-clang
    if [ $? -ne 0 ]; then
        echo "Error saving the Docker image."
        on_error
    fi
    gzip macos_compiler/containers/darwin-clang.tar
    echo "Hexio's macOS clang container saved successfully."
    cd $STARTDIR
}

tarball_plugin() {
    #We need to tarball macos_compiler to macos_compiler.tar.gz
    cd $BASEDIR
    mkdir -p build
    rm -f build/*
    #Tarball $BASEDIR/macos_compiler directory to build/macos_compiler.tar.gz
    tar -czf build/macos_compiler.tar.gz -C macos_compiler .
    echo "Hexio macOS compiler plugin tarball created at build/macos_compiler.tar.gz"
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
    echo "[!] Hexio macOS compiler plugin build completed."
    cd $STARTDIR
}

main