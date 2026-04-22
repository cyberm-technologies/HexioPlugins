#!/bin/bash

SCRIPT_ROOT=${PWD}

uninstall_scripts() {
    echo "Uninstalling scripts..."
    rm -f /usr/local/bin/android-clang
    rm -f /usr/local/bin/android-clang-arm64
    rm -f /usr/local/bin/android-clang-arm
    rm -f /usr/local/bin/android-clang-x64
    echo "Scripts uninstalled."
}

remove_containers() {
    echo "Removing Docker image..."
    docker rmi -f android-clang 2>/dev/null || true
    echo "Docker image removed."
}

delete_plugin_root() {
    echo "Purging plugin root directory..."
    cd $SCRIPT_ROOT
    rm -rf *
    echo "Plugin root directory purged."
}

main() {
    uninstall_scripts
    remove_containers
    delete_plugin_root
}

main
