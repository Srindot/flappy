# ------------------------------------------------------------------
# Purdue Flappy Simulation Environment (Ubuntu 18.04 / Python 3.6)
# Fully functional replacement for broken 16.04 image
# ------------------------------------------------------------------
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y python3 python3-dev python3-pip \
    build-essential cmake pkg-config git curl ca-certificates \
    libeigen3-dev libassimp-dev libboost-all-dev freeglut3-dev \
    libxi-dev libxmu-dev libnlopt-dev libopenmpi-dev zlib1g-dev swig \
    libfcl-dev libode-dev libtinyxml2-dev libglew-dev libgl1-mesa-dev \
    libosg-dev libosgViewer-dev libosgGA-dev libosgDB-dev \
 && update-ca-certificates && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip setuptools wheel

WORKDIR /opt
RUN git clone https://github.com/openscenegraph/OpenSceneGraph.git && \
    cd OpenSceneGraph && git checkout OpenSceneGraph-3.4 && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/OpenSceneGraph

RUN git clone https://github.com/dartsim/dart.git && \
    cd dart && git checkout tags/v6.1.2 && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DDART_BUILD_GUI_OSG=ON -DDART_BUILD_UTILS=ON .. && \
    make -j$(nproc) && make install && ldconfig && \
    cd / && rm -rf /opt/dart

RUN python3 -m pip install --no-cache-dir pydart2==0.3.11 \
    "numpy<=1.14.5" click tensorflow==1.9 stable-baselines==2.10.2 \
    "gym==0.17.3" "cloudpickle==1.6.0" "pyglet<=1.5.0" \
    "Pillow==7.2.0" "scipy==1.4.1" "PyQt5<=5.15.2"

WORKDIR /workspace
ENV PYTHONPATH=/workspace
CMD ["bash"]
