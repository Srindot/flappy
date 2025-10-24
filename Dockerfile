# ------------------------------------------------------------------
# Purdue Flappy Simulation Environment (Ubuntu 16.04 / Python 3.5)
# EOL‑safe variant for Docker Buildx (fully functional)
# ------------------------------------------------------------------
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------
# 0. Use archived repositories for Ubuntu 16.04
# ------------------------------------------------------------------
RUN sed -i 's|archive.ubuntu.com/ubuntu/|old-releases.ubuntu.com/ubuntu/|g' /etc/apt/sources.list && \
    sed -i 's|security.ubuntu.com/ubuntu/|old-releases.ubuntu.com/ubuntu/|g' /etc/apt/sources.list

# ------------------------------------------------------------------
# 1. Base system dependencies (split to avoid fetch errors)
# ------------------------------------------------------------------
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    python3 python3-dev python3-pip \
    build-essential cmake pkg-config git curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    software-properties-common apt-transport-https gnupg \
    libeigen3-dev libassimp-dev libboost-all-dev \
    freeglut3-dev libxi-dev libxmu-dev \
    libnlopt-dev libopenmpi-dev zlib1g-dev swig \
    libfcl-dev libode-dev libtinyxml2-dev && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# 2. OpenGL + OSG (manual build replaces missing apt packages)
# ------------------------------------------------------------------
WORKDIR /opt
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends libglew-dev libgl1-mesa-dev && \
    git clone https://github.com/openscenegraph/OpenSceneGraph.git && \
    cd OpenSceneGraph && \
    git checkout OpenSceneGraph-3.4 && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/OpenSceneGraph

# ------------------------------------------------------------------
# 3. Modern pip toolchain (Python 3.5‑compatible)
# ------------------------------------------------------------------
RUN python3 -m pip install --upgrade pip==20.3.4 setuptools<45 wheel<0.34

# ------------------------------------------------------------------
# 4. Build DART 6.1.2 (with GUI enabled)
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
# 5. Build PyDART2 against installed DART
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir pydart2==0.3.11

# ------------------------------------------------------------------
# 6. Simulation / RL Libraries (Python 3.5 era versions)
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir "numpy<=1.14.5"
RUN python3 -m pip install --no-cache-dir click tensorflow==1.9 stable-baselines==2.10.2 \
    "gym==0.17.3" "cloudpickle==1.6.0" "pyglet<=1.5.0" "Pillow==7.2.0" "scipy==1.4.1" "PyQt5<=5.15.2"

# ------------------------------------------------------------------
# 7. Workspace setup
# ------------------------------------------------------------------
WORKDIR /workspace
ENV PYTHONPATH=/workspace
CMD ["bash"]
