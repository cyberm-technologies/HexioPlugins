# =============================================================================
# Stage 1: Builder - Build osxcross toolchain
# =============================================================================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Copy xcode.xip early for layer caching
COPY xcodesdk/xcode.xip /tmp/xcode.xip

# Set timezone and install build dependencies
RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y \
    cmake git patch python3 curl wget \
    libssl-dev liblzma-dev xz-utils libxml2-dev bzip2 cpio libbz2-dev zlib1g-dev \
    autoconf automake libtool \
    gnupg software-properties-common lsb-release && \
    rm -rf /var/lib/apt/lists/*

# Clone osxcross
RUN cd /opt && git clone https://github.com/tpoechtrager/osxcross.git && \
    mkdir -p /opt/osxcross/tarballs

# Install Clang 19
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 19 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 100 && \
    rm llvm.sh && \
    rm -rf /var/lib/apt/lists/*

# Build osxcross
RUN cd /opt/osxcross && \
    ./tools/gen_sdk_package_pbzx.sh /tmp/xcode.xip && \
    mv /opt/osxcross/MacOSX15.5.sdk.tar.xz /opt/osxcross/tarballs/ && \
    UNATTENDED=1 ./build.sh

# Clean up build artifacts in builder stage
RUN rm -f /tmp/xcode.xip && \
    rm -f /opt/osxcross/*.sdk.tar.xz && \
    rm -f /opt/osxcross/tarballs/*.sdk.tar.xz && \
    rm -rf /opt/osxcross/.git && \
    rm -rf /opt/osxcross/build

# =============================================================================
# Stage 2: Runtime - Minimal image with only osxcross toolchain
# =============================================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        software-properties-common \
        lsb-release \
        gnupg && \
    curl -fsSL https://apt.llvm.org/llvm.sh -o llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 19 && \
    apt-get install -y \
        clang-19 \
        llvm-19 \
        lld-19 \
        llvm-19-dev \
        libclang-common-19-dev && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 100 && \
    update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-19 100 && \
    rm llvm.sh && \
    apt-get purge --auto-remove gnupg lsb-release curl wget -y && \
    rm -rf /var/lib/apt/lists/*

# Copy only the osxcross target directory (contains compilers and SDK)
COPY --from=builder /opt/osxcross/target /opt/osxcross/target

# Copy the clang-wrapper script
COPY clang-wrapper.sh /usr/bin/clang-wrapper.sh
RUN chmod +x /usr/bin/clang-wrapper.sh

ENV PATH="/opt/osxcross/target/bin:${PATH}"
ENV SYSROOT=/opt/osxcross/target/SDK/MacOSX15.5.sdk

WORKDIR /opt/code

ENTRYPOINT ["/usr/bin/clang-wrapper.sh", \
    "--sysroot=/opt/osxcross/target/SDK/MacOSX15.5.sdk", \
    "-F/opt/osxcross/target/SDK/MacOSX15.5.sdk/System/Library/Frameworks", \
    "-I/opt/osxcross/target/SDK/MacOSX15.5.sdk/usr/include", \
    "-L/opt/osxcross/target/SDK/MacOSX15.5.sdk/usr/lib"]

CMD ["--help"]