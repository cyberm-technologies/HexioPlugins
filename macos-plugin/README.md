# Hexio macOS Compiler Plugin

This repository contains the necessary components to build the **Hexio macOS Compiler Plugin**.

This plugin is **required** to compile native macOS payloads for the Hexio C2 Framework. Without it, Hexio will be unable to target macOS systems.

---

## ⚠️ Why do I need this plugin?

Due to restrictions on redistributing Apple’s macOS SDK (required for building C++ payloads), Hexio does not include macOS compiler support by default.

Instead, this plugin enables users with a **legally obtained copy of the Xcode SDK** to build a Docker container that the Teamserver can use to compile macOS implants.

The macOS payload is already present on the Teamserver, but remains **locked** until this plugin is installed.

Once installed, this plugin enables Hexio to compile native payloads targeting **both `x64` (Intel) and `arm64` (Apple Silicon)** macOS systems using a single unified compiler container.

---

## 🧰 Requirements
 - A valid Apple Developer account.
 - Docker installed on your build system
 - The `.xip` archive of Xcode downloaded from [Apple's Developer portal](https://developer.apple.com/download/all/?q=xcode%2016.4). **Note: this is designed around Xcode 16.4**, so ensure you download that version

---

## 📦 Preparing the SDK

1. Visit the Apple Developer downloads page:
    
    👉 https://developer.apple.com/download/all/?q=xcode%2016.4
2. Download the 16.4 version of **Xcode** (file ending in `.xip`)
3. Rename the downloaded file to `xcode.xip` and place it in the plugin's `xcodesdk` directory:
    ```bash
    mv ~/Downloads/Xcode_*.xip xcodesdk/xcode.xip
    ```
| 📁 Your plugin directory should now contain:
```bash
xcodesdk/xcode.xip
```

---

## 🔧 Building the Plugin
Once `xcode.xip` is in place, run the build script:
```bash
./build.sh
```
This script will:
 - Extract the required SDK from the Xcode archive
 - Install a [`osxcross`](https://github.com/tpoechtrager/osxcross) toolchain using the provided sdk into a Docker container
 - Package the compiler plugin into a `.tar.gz` archive

On success, it will generate:
```bash
build/macos_compiler.tar.gz
```

---

## 🚀 Installing the Plugin
To install the plugin:
 1. Log in to your Hexio Teamserver as a `root` or `admin` user
 2. Navigate to `Teamserver Management → Plugins`, then select the **macOS Compiler Plugin** tab.
 3. Click **Upload** and select the `build/macos_compiler.tar.gz` file
 4. Wait for the installation to complete

Once installed, Hexio will be able to compile and deploy **native macOS implants** for both Intel (`x64`) and Apple Silicon (`arm64`) systems using this compiler.

---

## 🔐 Licensing & SDK Notes

 - **This compiler plugin is free** and exists solely to offload SDK responsibility to users.
 - You must obtain the Xcode `.xip` file using your own Apple Developer credentials to legally build this plugin.

| Note: Without this plugin, Hexio cannot generate implants for macOS targets.