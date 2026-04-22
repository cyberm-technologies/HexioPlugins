# Hexio iOS Compiler Plugin

This repository contains the necessary components to build the Hexio iOS Compiler Plugin.

This plugin is **required** to compile iOS payloads for the Hexio C2 Framework. It enables support for targeting **arm64 iOS devices (iOS 13+)**, but **does not include the payload source code**. That is part of the **paid `ios_payload` plugin**.

---

## ⚠️ Why do I need this plugin?

Due to the legal restrictions surrounding redistribution of Apple’s iPhone SDK, Hexio **does not** ship a prebuilt iOS compiler.

Instead, we provide users with the tooling and bootstrap scripts to create a Docker container that includes a working iOS compiler **built using their own SDK**.

This lets you legally compile iOS payloads (if you already have access to the SDK), while allowing Hexio to remain compliant with Apple’s distribution terms.

Once built and installed, this plugin allows the Teamserver to compile iOS implants targeting arm64 devices running **iOS 13 and above**.

---

## 🧰 Requirements
 - Access to a macOS machine with Xcode installed.
 - Docker installed on your build system
 - iPhoneOS SDK files are located at:
    ```bash
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS<version>.sdk
    ```
 - You'll need to tar this SDK folder and move it into the `xcodesdk` directory

---

## 📦 Preparing the SDK
On a macOS machine with Xcode:

 1. Find your iPhone SDK directory:
    ```bash
    ls /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs
    ```
    You'll see something like:
    ```bash
    iPhoneOS18.1.sdk
    ```
 2. Tar the SDK directory:
    ```bash
    tar -czf iPhoneSDK.tar.gz -C /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs iPhoneOS18.1.sdk
    ```
 3. Proceed to move the resulting `iPhoneSDK.tar.gz` into this plugin's `xcodesdk` directory (This may also be moved to a Linux system via `scp` or other means)
    ```bash
    mv iPhoneSDK.tar.gz <ios-plugin>/xcodesdk
    ```

| 📁 Your plugin directory should now contain:
`xcodesdk/iPhoneSDK.tar.gz`

---

## 🔧 Building the Plugin

Once the `iPhoneSDK.tar.gz` is in place, simply run the build script:
```bash
./build.sh
```
This script will:
 - Build a Docker container that includes clang 19 and the iPhone SDK
 - Package the compiler plugin into a `.tar.gz` archive

On success, it will produce:
```bash
build/ios_compiler.tar.gz
```

---

## 🚀 Installing the Plugin
To install the plugin:
 1. Log in to your Hexio Teamserver interface as either the `root` user or an `admin` user
 2. Navigate to the `Teamserver Management → Plugins` pane and select the `iOS Compiler Plugin` pane
 3. Click upload and drop the `build/ios_compiler.tar.gz` into the file dialog
 4. Await installation confirmation

Once installed, Hexio will have the ability to compile **iOS payloads**, provided that the `ios_payload` **plugin** (sold separately) is also installed

---

## 🔐 Licensing & Payload Source

 - **This compiler plugin is free** and exists solely to offload SDK responsibility to users.
 - **The actual iOS payload (`ios_payload`) is a paid plugin,** available to qualified customers only.

| Note: Without both the iOS Compiler and the iOS Payload Plugin, Hexio cannot generate implants for iOS targets.
