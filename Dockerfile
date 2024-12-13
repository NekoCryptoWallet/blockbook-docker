# Base image setup
ARG BASE_IMAGE=ubuntu:20.04
FROM $BASE_IMAGE

# Maintainer information
MAINTAINER obi.nwamarah@gmail.com

# Arguments and environment variables
ARG DEBIAN_FRONTEND=noninteractive
ARG GOLANG_VERSION=go1.22.2
ARG ROCKSDB_VERSION=v7.7.2
ARG TCMALLOC
ARG TAG=master
ARG PORTABLE_ROCKSDB
ARG TARGETPLATFORM

ENV GOPATH=/home/blockbook/go
ENV HOME=/home/blockbook
ENV PATH="$PATH:$GOPATH/bin"
ENV CGO_CFLAGS="-I$HOME/rocksdb/include"
ENV CGO_LDFLAGS="-L$HOME/rocksdb -ldl -lrocksdb -lstdc++ -lm -lz -lbz2 -lsnappy -llz4 -lzstd"

# System dependencies installation
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends build-essential git wget pkg-config lxc-dev libzmq3-dev \
                       libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev libzstd-dev liblz4-dev graphviz \
                       google-perftools && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# User setup
RUN useradd -ms /bin/bash blockbook && mkdir -p $HOME/rocksdb/include && mkdir -p $GOPATH
USER blockbook

# Install Go
RUN cd /tmp && wget https://dl.google.com/go/go1.22.2.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz && rm -f go1.22.2.linux-amd64.tar.gz

RUN ln -s /usr/local/go/bin/go /usr/bin/go && \
    echo -n "GO version: " && go version

# Install RocksDB
RUN cd /tmp && git clone -b v7.7.2 --depth 1 https://github.com/facebook/rocksdb.git && \
    cd rocksdb && CFLAGS=-fPIC CXXFLAGS=-fPIC PORTABLE=$PORTABLE_ROCKSDB make -j4 release && \
    cp librock* /home/blockbook/rocksdb && cp -r include /home/blockbook/rocksdb && \
    rm -rf /tmp/rocksdb && go get github.com/tecbot/gorocksdb

# Install Blockbook dependencies and build
RUN cd /home/blockbook/go/src && git clone https://github.com/trezor/blockbook.git && \
    cd blockbook && git checkout master && go mod download && \
    BUILDTIME=$(date --iso-8601=seconds); \
    GITCOMMIT=$(git describe --always --dirty); \
    LDFLAGS="-X blockbook/common.version=${TAG} -X blockbook/common.gitcommit=${GITCOMMIT} -X blockbook/common.buildtime=${BUILDTIME}" && \
    go build -ldflags="-s -w ${LDFLAGS}" && rm -rf /home/blockbook/go/pkg/mod

# Copy scripts and configs
COPY launch.sh /home/blockbook
COPY blockchain_cfg.json /home/blockbook

# Expose necessary ports
EXPOSE 9030 9130

# Entry point
ENTRYPOINT /home/blockbook/launch.sh