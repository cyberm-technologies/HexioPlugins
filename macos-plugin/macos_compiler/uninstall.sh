#!/bin/bash
SCRIPT_ROOT=${PWD}

uninstall_scripts() {
    echo "Uninstalling scripts..."
    rm -f /usr/bin/darwin-clang-arm64
    rm -f /usr/bin/darwin-clang-x64
    echo "Scripts uninstalled."
}

remove_containers() {
    echo "Removing Docker image..."
    docker rmi -f darwin-clang 2>/dev/null || true
    echo "Docker image removed."
}

delete_plugin_root() {
    cd $SCRIPT_ROOT
    echo "Purging plugin root directory..."
    rm -rf *
    echo "Plugin root directory purged."
}

main() {
    uninstall_scripts
    remove_containers
    delete_plugin_root
}

main