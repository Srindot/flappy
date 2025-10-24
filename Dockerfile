# ------------------------------------------------------------------
# Purdue Flappy Simulation Environment (Ubuntu 16.04 / Python 3.5)
# ------------------------------------------------------------------
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------
# 1. Core System and GUI Dependencies
# ------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-dev python3-pip \
    build-essential cmake pkg-config git \
    curl ca-certificates software-properties-common \
    libeigen3-dev libassimp-dev libboost-all-dev \
    freeglut3-dev libxi-dev libxmu-dev \
    libnlopt-dev libopenmpi-dev zlib1g-dev swig \
    libfcl-dev libode-dev libtinyxml2-dev \
    libglew-dev libgl1-mesa-dev libosg-dev \
    libosgViewer-dev libosgGA-dev libosgDB-dev \
    python3-pyqt4 python3-pyqt4.qtopengl \
 && update-ca-certificates && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# 2. Modern pip toolchain (Python 3.5‑compatible)
# ------------------------------------------------------------------
RUN python3 -m pip install --upgrade "pip==20.3.4" "setuptools<45" "wheel<0.34"

# ------------------------------------------------------------------
# 3. Build and install DART v6.1.2 (with GUI enabled)
# ------------------------------------------------------------------
WORKDIR /opt
RUN git clone https://github.com/dartsim/dart.git && \
    cd dart && \
    git checkout tags/v6.1.2 && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DDART_BUILD_GUI_OSG=ON \
          -DDART_BUILD_UTILS=ON .. && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/dart

# ------------------------------------------------------------------
# 4. Build PyDART2 against installed DART
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir pydart2==0.3.11

# ------------------------------------------------------------------
# 5. RL Stack and Simulation Dependencies
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir "numpy<=1.14.5"
RUN python3 -m pip install --no-cache-dir \
    click tensorflow==1.9 stable-baselines==2.10.2 \
    "gym==0.17.3" "cloudpickle==1.6.0" \
    "pyglet<=1.5.0" "Pillow==7.2.0" "scipy==1.4.1"

# ------------------------------------------------------------------
# 6. Final Environment Setup
# ------------------------------------------------------------------
WORKDIR /workspace
ENV PYTHONPATH=/workspace:$PYTHONPATH

CMD ["bash"]
