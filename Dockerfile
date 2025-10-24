# ------------------------------------------------------------------
# Purdue Flappy Simulation Environment (Ubuntu 16.04 / Python 3.5)
# ------------------------------------------------------------------
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

# ------------------------------------------------------------------
# 1. System and Core Build Dependencies
# ------------------------------------------------------------------
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
    software-properties-common \
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
 && update-ca-certificates && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# 2. Fix and Pin Python Tools (Python 3.5-compatible versions)
# ------------------------------------------------------------------
RUN python3 -m pip install --upgrade "pip==20.3.4" "setuptools<45" "wheel<0.34"

# ------------------------------------------------------------------
# 3. Install DART v6.2.1 (from source)
# ------------------------------------------------------------------
WORKDIR /opt
RUN git clone https://github.com/dartsim/dart.git && \
    cd dart && \
    git checkout tags/v6.2.1 && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/dart

# ------------------------------------------------------------------
# 4. Install PyDART2 (requires DART libs via official PPA)
# ------------------------------------------------------------------
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:dartsim/ppa && \
    apt-get update && \
    apt-get install -y libdart6-all-dev swig && \
    python3 -m pip install --no-cache-dir pydart2==0.3.11

# ------------------------------------------------------------------
# 5. Core Python Dependencies for Flappy
# ------------------------------------------------------------------
RUN python3 -m pip install --no-cache-dir "numpy<=1.14.5"
RUN python3 -m pip install --no-cache-dir \
    click \
    tensorflow==1.9 \
    stable-baselines==2.10.2 \
    "gym==0.17.3" \
    "cloudpickle==1.6.0" \
    "pyglet<=1.5.0" \
    "Pillow==7.2.0" \
    "scipy==1.4.1"

# ------------------------------------------------------------------
# 6. Final Environment Setup
# ------------------------------------------------------------------
WORKDIR /workspace
ENV PYTHONPATH=/workspace:$PYTHONPATH

CMD ["bash"]
