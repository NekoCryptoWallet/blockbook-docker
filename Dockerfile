# Use a base image with Go 1.19.2 and RocksDB 7.7.2
FROM golang:1.19.2-buster AS build

# Install dependencies for RocksDB
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev liblz4-dev libzstd-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Build RocksDB 7.7.2
WORKDIR /tmp
RUN curl -L https://github.com/facebook/rocksdb/archive/refs/tags/v7.7.2.tar.gz | tar xz \
    && cd rocksdb-7.7.2 \
    && mkdir -p build && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && make -j$(nproc) \
    && make install \
    && ldconfig

# Install ZeroMQ (required for Blockbook)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libzmq3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up Blockbook build
ARG BLOCKBOOK_VERSION=0.4.0
WORKDIR /home
RUN git clone --depth 1 -b v$BLOCKBOOK_VERSION https://github.com/trezor/blockbook.git

WORKDIR /home/blockbook

# Build Blockbook with RocksDB 7.7.2 and Go 1.19.2
RUN go build -tags rocksdb_7_7 -ldflags="-X github.com/trezor/blockbook/common.version=$BLOCKBOOK_VERSION -X github.com/trezor/blockbook/common.gitcommit=$(git describe --always --dirty) -X github.com/trezor/blockbook/common.buildtime=$(date --iso-8601=seconds)" \
    && strip blockbook \
    && ./contrib/scripts/build-blockchaincfg.sh monacoin

# Final image
FROM debian:buster-slim

# Update sources for apt-get
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsnappy1v5 libzmq5 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up Blockbook runtime
RUN mkdir -p /blockbook/config
COPY --from=build /home/blockbook/blockbook /blockbook/
COPY --from=build /home/blockbook/build/blockchaincfg.json /blockbook/config/
COPY --from=build /home/blockbook/static/ /blockbook/static/

WORKDIR /blockbook

COPY launch.sh /home/blockbook/

RUN chmod +x /home/blockbook/launch.sh

ENTRYPOINT [ "/home/blockbook/launch.sh" ]

CMD [ "-sync" ]
