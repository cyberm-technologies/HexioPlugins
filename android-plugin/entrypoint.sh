#!/bin/bash
#
# Entrypoint for android-clang container.
# Uses system clang-18 (shared LLVM, supports -fpass-plugin) with NDK sysroot
# and NDK resource dir (compiler-rt builtins, libunwind, etc).
#
# -rtlib=compiler-rt + -unwindlib=libunwind prevents the linker from looking
# for libgcc (which the NDK does not ship).
#

NDK_TOOLCHAIN="/opt/android_toolchain/ndk/toolchains/llvm/prebuilt/linux-x86_64"
SYSROOT="${NDK_TOOLCHAIN}/sysroot"
NDK_RESOURCE_DIR="${NDK_TOOLCHAIN}/lib/clang/18"
API=21

case "${ANDROID_ARCH}" in
    arm64|aarch64)
        TARGET="aarch64-linux-android${API}"
        SSL_PREFIX="${SYSROOT}/usr"
        ;;
    arm|armv7)
        TARGET="armv7a-linux-androideabi${API}"
        SSL_PREFIX="${SYSROOT}/usr/local/android-arm"
        ;;
    x64|x86_64)
        TARGET="x86_64-linux-android${API}"
        SSL_PREFIX="${SYSROOT}/usr/local/android-x64"
        ;;
    *)
        # Default to arm64
        TARGET="aarch64-linux-android${API}"
        SSL_PREFIX="${SYSROOT}/usr"
        ;;
esac

exec clang++-18 \
    --target="${TARGET}" \
    --sysroot="${SYSROOT}" \
    -resource-dir "${NDK_RESOURCE_DIR}" \
    -I"${SYSROOT}/usr/include" \
    -I"${SSL_PREFIX}/include" \
    -L"${SSL_PREFIX}/lib" \
    -fuse-ld=lld-18 \
    -rtlib=compiler-rt \
    -unwindlib=libunwind \
    "$@"
