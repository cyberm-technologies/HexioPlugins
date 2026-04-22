# =============================================================================
# Stage 1: Builder - Install LLVM/Clang and extract SDK
# =============================================================================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Set timezone and install build dependencies
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y wget gnupg software-properties-common lsb-release xz-utils && \
    rm -rf /var/lib/apt/lists/*

# Install Clang 19
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 19 && \
    rm llvm.sh && \
    rm -rf /var/lib/apt/lists/*

# Extract iPhone SDK
RUN mkdir -p /opt/ios_toolchain
COPY xcodesdk/iPhoneSDK.tar.gz /tmp/iPhoneSDK.tar.gz
RUN tar -xzf /tmp/iPhoneSDK.tar.gz -C /opt/ios_toolchain && \
    rm /tmp/iPhoneSDK.tar.gz

# =============================================================================
# Stage 2: Runtime - Minimal image with only what's needed to compile
# =============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Install only runtime dependencies for clang
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libstdc++6 \
        libc6 \
        libgcc-s1 \
        zlib1g \
        libxml2 \
        curl \
        ca-certificates \
        software-properties-common \
        lsb-release \
        gnupg && \
    curl -fsSL https://apt.llvm.org/llvm.sh -o llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 19 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 100 && \
    update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-19 100 && \
    rm llvm.sh && \
    apt-get purge --auto-remove gnupg lsb-release curl wget -y && \
    rm -rf /var/lib/apt/lists/*

# Copy the iOS SDK
COPY --from=builder /opt/ios_toolchain /opt/ios_toolchain

WORKDIR /opt/code

ENTRYPOINT ["/usr/bin/clang++", \
    "-target", "arm64-apple-ios13.0", \
    "-isysroot", "/opt/ios_toolchain", \
    "--sysroot", "/opt/ios_toolchain", \
    "-F/opt/ios_toolchain/System/Library/Frameworks", \
    "-I", "/opt/ios_toolchain/usr/include", \
    "-L", "/opt/ios_toolchain/usr/lib", \
    "-fuse-ld=lld"]