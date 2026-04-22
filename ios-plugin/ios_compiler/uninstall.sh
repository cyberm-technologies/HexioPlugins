#!/bin/bash

SCRIPT_ROOT=${PWD}

uninstall_script() {
    echo "Uninstalling scripts..."
    rm -f /usr/local/bin/ios-clang
    echo "Scripts uninstalled."
}

remove_containers() {
    echo "Removing Docker image..."
    docker rmi -f ios-clang 2>/dev/null || true
    echo "Docker image removed."
}

delete_plugin_root() {
    echo "Purging plugin root directory..."
    cd $SCRIPT_ROOT
    rm -rf *
    echo "Plugin root directory purged."
}

main() {
    uninstall_script
    remove_containers
    delete_plugin_root
}

main