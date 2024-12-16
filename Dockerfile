FROM ubuntu:latest

WORKDIR /explorer
RUN apt update
RUN apt install -y build-essential software-properties-common lz4 zstd libsnappy-dev libbz2-dev libzmq3-dev golang librocksdb-dev liblz4-dev libjemalloc-dev libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev libzstd-dev git
WORKDIR go
ENV GOPATH=/explorer/go
WORKDIR src
RUN git clone https://github.com/DeanSparrow/PIVX-BlockExplorer.git
WORKDIR PIVX-BlockExplorer
COPY docker/blockchainconfig.json .
RUN go mod init || echo
RUN go mod tidy || echo
RUN go build || echo
RUN ./build.sh
 
# Copy startup scripts
COPY launch.sh /explorer

COPY blockchain_cfg.json /explorer/go/src/PIVX-BlockExplorer/

EXPOSE 9030 9130

ENTRYPOINT /explorer/launch.sh