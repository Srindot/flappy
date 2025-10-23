# Base image: Ubuntu 16.04 (Xenial)
# Required for 'python3-pyqt4'
FROM ubuntu:16.04

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# 1. Install ALL System Dependencies (for DART, Python, and Flappy)
RUN apt-get update && apt-get install -y --no-install-recommends \
    # For Python
    python3 \
    python3-dev \
    curl \
    # For DART (build tools)
    build-essential \
    cmake \
    pkg-config \
    git \
    # For DART (libraries)
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
    # CRITICAL FIX 1: DART's GUI dependencies (fixes LoadGlut.hpp)
    freeglut3-dev \
    libxi-dev \
    libxmu-dev \
    # CRITICAL FIX 2: DART's Optimizer dependency (fixes -ldart-optimizer-nlopt)
    libnlopt-dev \
    # For Flappy (from README)
    libopenmpi-dev \
    zlib1g-dev \
    swig \
    python3-pyqt4 \
    python3-pyqt4.qtopengl \
# Clean up apt cache
&& rm -rf /var/lib/apt/lists/*

# 2. CRITICAL FIX 3: Manually install the correct pip/setuptools/wheel for Python 3.5
#    (This fixes all the Python 3.5 SyntaxError problems)
RUN curl https://bootstrap.pypa.io/pip/3.5/get-pip.py -o get-pip.py
RUN python3 get-pip.py \
    "pip<=21.3.1" \
    "setuptools<59" \
    "wheel<0.38"
RUN rm get-pip.py

# 3. Install DART v6.2.1 from source
#    (This will now build correctly with GUI and Optimizer support)
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

# 4. CRITICAL FIX 4: Install Python Packages in the correct order
#    (Install numpy first to fix the numpy/arrayobject.h error)
RUN pip3 install "numpy<=1.14.5"
RUN pip3 install \
    click \
    pydart2 \
    tensorflow==1.9

# 5. Set the final working directory for the dev container
WORKDIR /app

# Set a default command to keep the container running
CMD ["bash"]