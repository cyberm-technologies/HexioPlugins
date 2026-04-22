#!/bin/bash

#The script will be placed into its own directory prior to being called
SCRIPT_ROOT=${PWD}

on_error() {
    rm -f /usr/local/bin/android-clang
    rm -f /usr/local/bin/android-clang-arm64
    rm -f /usr/local/bin/android-clang-arm
    rm -f /usr/local/bin/android-clang-x64
    echo "An error occurred during installation. Please check the logs."
    echo "Installation failed. Please try again."
    exit 1
}

load_scripts() {
    cd $SCRIPT_ROOT
    cd scripts
    cp android-clang /usr/local/bin/android-clang
    cp android-clang-arm64 /usr/local/bin/android-clang-arm64
    cp android-clang-arm /usr/local/bin/android-clang-arm
    cp android-clang-x64 /usr/local/bin/android-clang-x64
    chmod +x /usr/local/bin/android-clang
    chmod +x /usr/local/bin/android-clang-arm64
    chmod +x /usr/local/bin/android-clang-arm
    chmod +x /usr/local/bin/android-clang-x64
    cd ..
}

load_container() {
    cd $SCRIPT_ROOT
    cd containers
    if [[ ! -f android-clang.tar.gz ]]; then
        on_error
    fi
    gunzip -c android-clang.tar.gz | docker load
    echo "Docker image loaded successfully."
}

cleanup() {
    cd $SCRIPT_ROOT
    rm -rf scripts
    rm -rf containers
    echo "Temporary files cleaned up."
}

main() {
    trap on_error ERR

    echo "Installing Hexio Android Compiler plugin..."

    # Load scripts
    load_scripts

    # Load containers
    load_container

    #Cleanup
    cleanup

    echo "Hexio Android Compiler plugin installed successfully."
}

main
