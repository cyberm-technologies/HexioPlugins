# =============================================================================
# Builder stage - compiles dependencies for all Android targets
# Uses mbedTLS instead of OpenSSL for significantly smaller binaries
# =============================================================================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN mkdir -p /opt/android_toolchain

RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get update && \
    apt-get install -y \
    cmake git patch python3 curl wget unzip zip make perl \
    libc6-dev libncurses5 libncurses5-dev \
    libstdc++6 libstdc++-11-dev && \
    rm -rf /var/lib/apt/lists/*

ENV ANDROID_NDK_VERSION=r27
ENV ANDROID_NDK_ZIP=android-ndk-${ANDROID_NDK_VERSION}-linux.zip
ENV ANDROID_NDK_URL=https://dl.google.com/android/repository/${ANDROID_NDK_ZIP}

RUN cd /opt/android_toolchain && \
    wget ${ANDROID_NDK_URL} && \
    unzip ${ANDROID_NDK_ZIP} && \
    rm ${ANDROID_NDK_ZIP} && \
    mv android-ndk-${ANDROID_NDK_VERSION} ndk

# Environment paths
ENV ANDROID_NDK=/opt/android_toolchain/ndk
ENV TOOLCHAIN=${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64
ENV PATH="${TOOLCHAIN}/bin:${PATH}"
ENV SYSROOT="${TOOLCHAIN}/sysroot"
ENV ANDROID_API=21

# ─────────────────────────────────────────────────────────────
# Build mbedTLS for all Android targets (arm64, arm, x64)
# ~300KB static vs ~4MB for OpenSSL
# ─────────────────────────────────────────────────────────────
RUN cd /tmp && \
    git clone --depth 1 --branch v3.6.3 https://github.com/Mbed-TLS/mbedtls.git && \
    cd mbedtls && git submodule update --init

# mbedTLS: arm64
RUN cd /tmp/mbedtls && \
    rm -rf build && mkdir build && cd build && \
    cmake .. \
        -DCMAKE_SYSTEM_NAME=Android \
        -DCMAKE_ANDROID_NDK=${ANDROID_NDK} \
        -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
        -DCMAKE_ANDROID_API=${ANDROID_API} \
        -DCMAKE_INSTALL_PREFIX=${SYSROOT}/usr \
        -DENABLE_TESTING=OFF \
        -DENABLE_PROGRAMS=OFF \
        -DCMAKE_C_FLAGS="-fPIC -Oz" \
        -DUSE_SHARED_MBEDTLS_LIBRARY=OFF \
        -DUSE_STATIC_MBEDTLS_LIBRARY=ON && \
    make -j$(nproc) && \
    make install

# mbedTLS: arm
RUN cd /tmp/mbedtls && \
    rm -rf build && mkdir build && cd build && \
    cmake .. \
        -DCMAKE_SYSTEM_NAME=Android \
        -DCMAKE_ANDROID_NDK=${ANDROID_NDK} \
        -DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a \
        -DCMAKE_ANDROID_API=${ANDROID_API} \
        -DCMAKE_INSTALL_PREFIX=${SYSROOT}/usr/local/android-arm \
        -DENABLE_TESTING=OFF \
        -DENABLE_PROGRAMS=OFF \
        -DCMAKE_C_FLAGS="-fPIC -Oz" \
        -DUSE_SHARED_MBEDTLS_LIBRARY=OFF \
        -DUSE_STATIC_MBEDTLS_LIBRARY=ON && \
    make -j$(nproc) && \
    make install

# mbedTLS: x64
RUN cd /tmp/mbedtls && \
    rm -rf build && mkdir build && cd build && \
    cmake .. \
        -DCMAKE_SYSTEM_NAME=Android \
        -DCMAKE_ANDROID_NDK=${ANDROID_NDK} \
        -DCMAKE_ANDROID_ARCH_ABI=x86_64 \
        -DCMAKE_ANDROID_API=${ANDROID_API} \
        -DCMAKE_INSTALL_PREFIX=${SYSROOT}/usr/local/android-x64 \
        -DENABLE_TESTING=OFF \
        -DENABLE_PROGRAMS=OFF \
        -DCMAKE_C_FLAGS="-fPIC -Oz" \
        -DUSE_SHARED_MBEDTLS_LIBRARY=OFF \
        -DUSE_STATIC_MBEDTLS_LIBRARY=ON && \
    make -j$(nproc) && \
    make install

RUN rm -rf /tmp/mbedtls

# ─────────────────────────────────────────────────────────────
# Build zlib for all Android targets
# ─────────────────────────────────────────────────────────────
RUN cd /tmp && \
    git clone --depth 1 https://github.com/madler/zlib.git

# zlib: arm64
RUN cd /tmp/zlib && \
    make distclean 2>/dev/null; true && \
    CC=aarch64-linux-android${ANDROID_API}-clang \
    CHOST=aarch64-linux-android \
    ./configure --prefix=${SYSROOT}/usr --static && \
    make -j$(nproc) && make install && make distclean

# zlib: arm
RUN cd /tmp/zlib && \
    CC=armv7a-linux-androideabi${ANDROID_API}-clang \
    CHOST=arm-linux-androideabi \
    ./configure --prefix=${SYSROOT}/usr/local/android-arm --static && \
    make -j$(nproc) && make install && make distclean

# zlib: x64
RUN cd /tmp/zlib && \
    CC=x86_64-linux-android${ANDROID_API}-clang \
    CHOST=x86_64-linux-android \
    ./configure --prefix=${SYSROOT}/usr/local/android-x64 --static && \
    make -j$(nproc) && make install && make distclean

RUN rm -rf /tmp/zlib

# =============================================================================
# Final stage - uses system clang-18 (shared LLVM) so -fpass-plugin works
# NDK sysroot is kept for Android headers, libs, and linker
# =============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install system clang-18 with shared LLVM libs (needed for -fpass-plugin)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libncurses5 libstdc++6 \
    wget gnupg ca-certificates lsb-release software-properties-common && \
    wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 18 && \
    rm -f llvm.sh && \
    apt-get install -y --no-install-recommends \
    clang-18 lld-18 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy NDK toolchain (includes compiled libs in sysroot) from builder
COPY --from=builder /opt/android_toolchain/ndk /opt/android_toolchain/ndk

# Environment paths
ENV ANDROID_NDK=/opt/android_toolchain/ndk
ENV PATH="${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}"
ENV ANDROID_API=21

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /opt/code

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
