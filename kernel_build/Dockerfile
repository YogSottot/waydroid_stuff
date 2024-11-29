FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["bash", "-c"]

RUN echo -e "USE_CCACHE=1" >> ~/.bashrc && \
    echo -e "CCACHE_EXEC=/usr/bin/ccache" >> ~/.bashrc

RUN sed -i 's/Types\:\ deb/Types\:\ deb\ deb-src/g' /etc/apt/sources.list.d/ubuntu.sources && \
    apt update && apt upgrade -y && \
    apt -y install wget && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb && \
    apt install ./libtinfo5_6.3-2ubuntu0.1_amd64.deb -y && rm -f libtinfo5_6.3-2ubuntu0.1_amd64.deb && \
    wget http://archive.ubuntu.com/ubuntu/pool/universe/n/ncurses/libncurses5_6.3-2ubuntu0.1_amd64.deb && \
    apt install -y ./libncurses5_6.3-2ubuntu0.1_amd64.deb && rm -f libncurses5_6.3-2ubuntu0.1_amd64.deb && \
    apt install -y \
    curl \
    build-essential \
    libssl-dev \
    bc \
    git \
    unzip \
    wget \
    python3 \
    python-is-python3 \
    python3-pip \
    python3-mako \
    python3-pil \
    python3-ply \
    python3-packaging \
    python3-setuptools \
    python3-requests \
    python3-pycparser \
    cmake \
    gcc \
    ninja-build \
    ccache \
    zip \
    lsb-release \
    software-properties-common \
    gnupg \
    glslang-tools \
    bison \
    flex \
    g++-multilib \
    gcc-multilib \
    git-lfs \
    gperf \
    imagemagick \
    lib32readline-dev \
    lib32z1-dev \
    libelf-dev \
    liblz4-tool \
    libsdl1.2-dev \
    libxml2 \
    libxml2-utils \
    libxml2-dev \
    lzop \
    pngcrush \
    rsync \
    schedtool \
    squashfs-tools \
    xsltproc \
    zlib1g-dev \
    lib32ncurses-dev \
    libncurses6 \
    libncurses-dev \
    libnss3-tools \
    libarchive-dev \
    libclang-cpp-dev \
    libglvnd-dev \
    liblua5.3-dev \
    ocl-icd-opencl-dev \
    shellcheck \
    time \
    zstd \
    dpkg-cross \
    kmod \
    libepoxy-dev \ 
    libgtk-3-dev \
    libomxil-bellagio-dev \
    libunwind-dev \
    x11proto-dri2-dev \
    x11proto-gl-dev \
    x11proto-randr-dev \
    unzip \
    libreadline-dev \
    android-sdk-libsparse-utils \
    meson && \
    apt build-dep -y mesa && \
    apt clean all && rm -rf /var/lib/apt/lists/*
    
# Setup git config
ARG GIT_NAME="YogSottot"
ENV GIT_NAME=${GIT_NAME}
ARG GIT_EMAIL="7411302+YogSottot@users.noreply.github.com"
ENV GIT_EMAIL=${GIT_EMAIL}
RUN git config --global user.name "${GIT_NAME}"
RUN git config --global user.email "${GIT_EMAIL}"
# Enable color output (optional)
RUN git config --global color.ui true
# Set options for lineage build
RUN git lfs install
RUN git config --global trailer.changeid.key "Change-Id"
# Pull rebase by default or supply ARG PULL_REBASE=false
ARG PULL_REBASE=true
ENV PULL_REBASE=${PULL_REBASE}
RUN git config --global pull.rebase ${PULL_REBASE}

# Install and setup latest repo, if needed
RUN curl -s https://storage.googleapis.com/git-repo-downloads/repo -o /usr/local/bin/repo \
        && chmod a+x /usr/local/bin/repo \
        && repo --version

RUN wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip && \
    unzip platform-tools-latest-linux.zip -d ~ && \
    rm platform-tools-latest-linux.zip && \
    <<EOF cat >> ~/.profile
    # add Android SDK platform tools to path
    if [ -d "$HOME/platform-tools" ] ; then
    PATH="$HOME/platform-tools:$PATH"
    fi
EOF


# Download and install latest clang
#RUN curl -s https://apt.llvm.org/llvm.sh > /tmp/llvm.sh \
#        && chmod a+x /tmp/llvm.sh \
#        && /tmp/llvm.sh all \
#        && export LLVM_VERSION=$(cat /tmp/llvm.sh | grep -oP 'CURRENT_LLVM_STABLE=(\K[0-9.]+)') \
#        && for i in $(ls /usr/lib/llvm-$"LLVM_VERSION"/bin) ; do  ln -s /usr/lib/llvm-$"LLVM_VERSION"/bin/$"i" /usr/bin/$"i" ; done \
#        && rm /tmp/llvm.sh

CMD [ "bash", "-c" ]
