# Base image: Ubuntu 16.04 (Xenial)
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install all system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    ca-certificates \
    curl \
    build-essential \
    cmake \
    pkg-config \
    git \
    libeigen3-dev \
    libassimp-dev \
    libboost-regex-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libbullet-dev \
    libfcl-dev \
    libode-dev \
    libtinyxml2-dev \
    liburdfdom-dev \
    liburdfdom-headers-dev \
    freeglut3-dev \
    libxi-dev \
    libxmu-dev \
    libnlopt-dev \
    libopenmpi-dev \
    zlib1g-dev \
    swig \
    python3-pyqt4 \
    python3-pyqt4.qtopengl \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 2. Pin pip/setuptools/wheel to Python 3.5–compatible versions
# pip 20.3.4 is the last version that supports Python 3.5
RUN python3 -m pip install --upgrade "pip==20.3.4" "setuptools<45" "wheel<0.34"

# 3. Build and install DART v6.2.1
WORKDIR /opt
RUN git clone https://github.com/dartsim/dart.git && \
    cd dart && \
    git checkout tags/v6.2.1 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd / && \
    rm -rf /opt/dart

# 4. Install Python dependencies
# Install numpy first to avoid build dependency mismatches
RUN python3 -m pip install "numpy<=1.14.5"
RUN python3 -m pip install \
    click \
    pydart2 \
    tensorflow==1.9

# 5. Working directory
WORKDIR /app

CMD ["bash"]
