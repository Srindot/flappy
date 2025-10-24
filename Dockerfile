# ------------------------------------------------------------------
# Purdue Flappy Simulation Environment (Ubuntu 16.04 / Python 3.5)
# Compatible with DART 6.1.2 + PyDART2 0.3.11 + Gym 0.17.3
# ------------------------------------------------------------------
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------
# 0. Redirect apt sources to archived Ubuntu Xenial (EOL)
# ------------------------------------------------------------------
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|http://old-releases.ubuntu.com/ubuntu/|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|http://old-releases.ubuntu.com/ubuntu/|g' /etc/apt/sources.list

# ------------------------------------------------------------------
# 1. Core Build + Graphical Dependencies
# ------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-dev python3-pip \
    build-essential cmake pkg-config git \
    curl ca-certificates software-properties-common \
    apt-transport-https gnupg \
    libeigen3-dev libassimp-dev libboost-all-dev \
    freeglut3-dev libxi-dev libxmu-dev \
    libnlopt-dev libopenmpi-dev zlib1g-dev swig \
    libfcl-dev libode-dev libtinyxml2-dev \
    libglew-dev libgl1-mesa-dev \
 && update-ca-certificates && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# 2. Build OpenSceneGraph from source (since old libs vanished)
# ------------------------------------------------------------------
WORKDIR /opt
RUN git clone https://github.com/openscenegraph/OpenSceneGraph.git && \
    cd OpenSceneGraph && \
    git checkout OpenSceneGraph-3.4 && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/OpenSceneGraph

# ------------------------------------------------------------------
# 3. Python Toolchain compatible with Python 3.5
# ------------------------------------------------------------------
RUN python3 -m pip install --upgrade "pip==20.3.4" "setuptools<45" "wheel<0.34"

# ------------------------------------------------------------------
# 4. Build and Install DART 6.1.2 (with GUI enabled)
# ------------------------------------------------------------------
WORKDIR /opt
RUN git clone https://github.com/dartsim/dart.git && \
    cd dart && \
    git checkout tags/v6.1.2 && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DDART_BUILD_UTILS=ON \
          -DDART_BUILD_GUI_OSG=ON .. && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/dart

# ------------------------------------------------------------------
# 5. Build PyDART2 against DART (confirmed compatible)
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir pydart2==0.3.11

# ------------------------------------------------------------------
# 6. Simulation + RL Libraries (locked for Python 3.5)
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir "numpy<=1.14.5"
RUN python3 -m pip install --no-cache-dir \
    click tensorflow==1.9 stable-baselines==2.10.2 \
    "gym==0.17.3" "cloudpickle==1.6.0" \
    "pyglet<=1.5.0" "Pillow==7.2.0" "scipy==1.4.1" \
    "PyQt5<=5.15.2"

# ------------------------------------------------------------------
# 7. Final Workspace Setup
# ------------------------------------------------------------------
WORKDIR /workspace
ENV PYTHONPATH=/workspace
CMD ["bash"]
