FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda


# 安装构建依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev \
    git git-lfs \
    wget curl unzip nano vim tmux htop \
    build-essential \
    libgl1-mesa-glx \
    cmake pkg-config libgsl-dev zlib1g-dev \
    bison flex perl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y wget && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/opt/conda/bin:$PATH"

RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda install -y viennarna

# 清理源码
RUN rm -rf /opt/ViennaRNA

# 设置 python/pip 默认指向 python3
RUN ln -sf /usr/bin/python3 /usr/bin/python && ln -sf /usr/bin/pip3 /usr/bin/pip

# 安装 PyTorch + CUDA 11.7 版本
RUN pip install --upgrade pip && pip install \
    torch==2.0.1 \
    torchvision==0.15.2 \
    "networkx<3.0" \
    --extra-index-url https://download.pytorch.org/whl/cu117

# 安装 DeepSpeed + Lightning 等依赖
RUN pip install \
    pytorch-lightning==1.9.5 \
    deepspeed==0.16.7 \
    torchmetrics==0.11.4 \
    numpy \
    pandas \
    sentencepiece \
    tqdm \
    matplotlib \
    wandb \
    scikit-learn \
    jupyterlab \
    ipywidgets \
    notebook

WORKDIR /

