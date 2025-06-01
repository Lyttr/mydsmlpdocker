# 1) choose base container
# generally use the most recent tag

# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain
ARG BASE_CONTAINER=ucsdets/datahub-base-notebook:2023.2-stable

FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root to install packages
USER root

# 安装系统依赖（含 RNAfold 构建工具）
RUN apt-get update && apt-get install -y --no-install-recommends \
    git git-lfs \
    wget curl unzip nano vim tmux htop \
    build-essential \
    libgl1-mesa-glx \
    cmake pkg-config libgsl-dev zlib1g-dev \
    bison flex perl \
    autoconf automake libtool \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN curl -LO https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_6_x/ViennaRNA-2.6.4.tar.gz && \
    tar -xzf ViennaRNA-2.6.4.tar.gz && \
    cd ViennaRNA-2.6.4 && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    cd / && rm -rf ViennaRNA-2.6.4*

# 3) install packages using notebook user
USER jovyan

# 安装 PyTorch + CUDA 11.7
RUN pip install --upgrade pip && pip install \
    torch==2.0.1 \
    torchvision==0.15.2 \
    --extra-index-url https://download.pytorch.org/whl/cu117

# 安装 Python 库（含 DeepSpeed, Lightning 等）
RUN pip install --no-cache-dir \
    pytorch-lightning==1.9.5 \
    deepspeed==0.16.7 \
    torchmetrics==0.11.4 \
    numpy pandas \
    sentencepiece \
    tqdm \
    matplotlib \
    wandb \
    scikit-learn \
    networkx<3.0 \
    ipywidgets

# ✅ 仍使用 Datahub 默认启动方式（start-notebook.sh）
