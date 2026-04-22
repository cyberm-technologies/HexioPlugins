# Hexio Android Compiler Plugin

This repository contains the necessary components to build the **Hexio Android Compiler Plugin**.

This plugin is **required** to compile native Android payloads for the Hexio C2 Framework. Without it, Hexio will be unable to target Android systems.

---

## ⚠️ Why do I need this plugin?

Unlike the iOS and macOS plugins, the Android compiler plugin does **not** require any proprietary SDKs from the user. The Android NDK is freely redistributable.

However, due to the size of the compiler container and the inclusion of pre-built dependencies (OpenSSL, zlib, libcurl), we ship this as a separate plugin to keep the core Teamserver lightweight.

Once installed, this plugin enables Hexio to compile native payloads targeting **arm64 Android devices (API level 21+, Android 5.0 Lollipop and above)**.

---

## 🧰 Requirements
 - Docker installed on your build system
 - Internet connection (to download the Android NDK and build dependencies)

---

## 🔧 Building the Plugin

Simply run the build script:
```bash
./build.sh
```
This script will:
 - Download the Android NDK (r27)
 - Clone and build zlib, OpenSSL, and libcurl for Android arm64
 - Package the compiler plugin into a `.tar.gz` archive

On success, it will generate:
```bash
build/android_compiler.tar.gz
```

---

## 🚀 Installing the Plugin
To install the plugin:
 1. Log in to your Hexio Teamserver as a `root` or `admin` user
 2. Navigate to `Teamserver Management → Plugins`, then select the **Android Compiler Plugin** tab.
 3. Click **Upload** and select the `build/android_compiler.tar.gz` file
 4. Wait for the installation to complete

Once installed, Hexio will be able to compile and deploy **native Android implants** for arm64 devices using this compiler.

---

## 📦 Included Libraries

The Android compiler container comes pre-built with the following libraries for cross-compilation:

| Library | Description |
|---------|-------------|
| **zlib** | Compression library |
| **OpenSSL** | TLS/SSL and cryptography |
| **libcurl** | HTTP/HTTPS client library |

These are statically compiled for Android arm64 and installed into the NDK sysroot.

---

## 🔐 Licensing & Payload Source

 - **This compiler plugin is free** and contains only open-source components (Android NDK, zlib, OpenSSL, libcurl).
 - **The actual Android payload (`android_payload`) is a paid plugin,** available to qualified customers only.

| Note: Without both the Android Compiler and the Android Payload Plugin, Hexio cannot generate implants for Android targets.
