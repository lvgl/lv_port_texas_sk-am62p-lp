FROM debian:latest

# Set environment variables to avoid interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install necessary packages, including Git
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    cmake \
    libdrm-dev \
    libsdl2-dev \
    libsdl2-image-dev \
    build-essential \
    ca-certificates \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a working directory and clone the repository with submodules
RUN mkdir /workdir && \
    cd /workdir && \
    git clone --recurse-submodules https://github.com/lvgl/lv_port_linux.git

# Set the default working directory for the container
WORKDIR /workdir/lv_port_linux

# Copy the lv_conf.h from the build context to the repository
COPY lv_conf.h /workdir/lv_port_linux/lv_conf.h

# Verify that GCC, G++, and CMake are installed
RUN gcc --version && g++ --version && cmake --version

# Build the project
RUN cmake -B build-arm64 -S . && \
    make -j $(nproc) -C build-arm64

# Default command to start a shell
CMD ["/bin/bash"]
