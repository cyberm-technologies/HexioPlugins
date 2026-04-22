#!/bin/bash

#The script will be placed into its own directory prior to being called
SCRIPT_ROOT=${PWD}

on_error() {
    rm -f /usr/local/bin/ios-clang
    echo "An error occurred during installation. Please check the logs."
    echo "Installation failed. Please try again."
    exit 1
}

load_scripts() {
    cd $SCRIPT_ROOT
    cd scripts
    cp ios-clang /usr/local/bin/ios-clang
    chmod +x /usr/local/bin/ios-clang
    cd ..
}

load_container() {
    cd $SCRIPT_ROOT
    cd containers
    if [[ ! -f ios-clang.tar.gz ]]; then
        on_error
    fi
    gunzip -c ios-clang.tar.gz | docker load
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

    echo "Installing Hexio iOS Compiler plugin..."

    # Load scripts
    load_scripts

    # Load containers
    load_container

    #Cleanup
    cleanup

    echo "Hexio iOS Compiler plugin installed successfully."
}

main