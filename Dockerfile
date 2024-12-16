FROM ubuntu:latest

WORKDIR /explorer
RUN apt update
RUN apt install -y build-essential software-properties-common lz4 zstd libsnappy-dev libbz2-dev libzmq3-dev golang librocksdb-dev liblz4-dev libjemalloc-dev libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev libzstd-dev git
WORKDIR go
ENV GOPATH=/explorer/go
WORKDIR src
RUN git clone https://github.com/DeanSparrow/PIVX-BlockExplorer.git
WORKDIR PIVX-BlockExplorer
COPY blockchainconfig.json .
RUN go mod init || echo
RUN go mod tidy || echo
RUN go build || echo
RUN ./build.sh
ENTRYPOINT ["bin/blockbook"]
CMD ["-sync", "-resyncindexperiod=60017",  "-resyncmempoolperiod=60017",  "-blockchaincfg=/explorer/go/src/PIVX-BlockExplorer/blockchainconfig.json", "-internal=:9049", "-public=:9149", "-logtostderr"]
EXPOSE 9149 9049
