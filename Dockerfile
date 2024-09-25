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
    wayland-protocols \
    build-essential \
    ca-certificates \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verify that GCC, G++, and CMake are installed
RUN gcc --version && g++ --version && cmake --version

COPY img_benchmark_cogwheel_rgb.c /workdir/lv_port_linux/lvgl/demos/benchmark/assets/img_benchmark_cogwheel_rgb.c








