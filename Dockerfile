# ------------------------------------------------------------------
# Purdue Flappy Simulation Environment (Ubuntu 18.04 / Python 3.6)
# ------------------------------------------------------------------
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------
# 1. Enable "universe" repo and install core build dependencies
# ------------------------------------------------------------------
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 python3-dev python3-pip \
        build-essential cmake pkg-config git curl ca-certificates \
        libeigen3-dev libassimp-dev libboost-all-dev freeglut3-dev \
        libxi-dev libxmu-dev libnlopt-dev libopenmpi-dev zlib1g-dev swig \
        libfcl-dev libode-dev libtinyxml2-dev libglew-dev libgl1-mesa-dev \
 && update-ca-certificates && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# 2. Install modern (Python 3.6‑compatible) pip/setuptools/wheel
# ------------------------------------------------------------------
RUN python3 -m pip install --upgrade "pip==20.3.4" "setuptools<45" "wheel<0.34"

# ------------------------------------------------------------------
# 3. Build and install OpenSceneGraph 3.4 (for DART GUI support)
# ------------------------------------------------------------------
WORKDIR /opt
RUN git clone https://github.com/openscenegraph/OpenSceneGraph.git && \
    cd OpenSceneGraph && git checkout OpenSceneGraph-3.4 && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/OpenSceneGraph

# ------------------------------------------------------------------
# 4. Build and install DART v6.1.2 (with GUI enabled)
# ------------------------------------------------------------------
RUN git clone https://github.com/dartsim/dart.git && \
    cd dart && git checkout tags/v6.1.2 && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DDART_BUILD_GUI_OSG=ON \
          -DDART_BUILD_UTILS=ON .. && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/dart

# ------------------------------------------------------------------
# 5. Build PyDART2 (compatible with DART 6.1.2)
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir pydart2==0.3.11

# ------------------------------------------------------------------
# 6. Install Reinforcement Learning & Simulation Dependencies
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir "numpy<=1.14.5"
RUN python3 -m pip install --no-cache-dir \
    click tensorflow==1.9 stable-baselines==2.10.2 \
    "gym==0.17.3" "cloudpickle==1.6.0" \
    "pyglet<=1.5.0" "Pillow==7.2.0" "scipy==1.4.1" "PyQt5<=5.15.2"

# ------------------------------------------------------------------
# 7. Final workspace setup
# ------------------------------------------------------------------
WORKDIR /workspace
ENV PYTHONPATH=/workspace

CMD ["bash"]
