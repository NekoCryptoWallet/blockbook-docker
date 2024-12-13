FROM gostartups/golang-rocksdb-zeromq:andromeda AS build

ARG BLOCKBOOK_VERSION=0.4.0

WORKDIR /home

RUN git clone --depth 1 -b v$BLOCKBOOK_VERSION https://github.com/trezor/blockbook.git

WORKDIR /home/blockbook

RUN go build -tags rocksdb_6_16 -ldflags="-X github.com/trezor/blockbook/common.version=$BLOCKBOOK_VERSION -X github.com/trezor/blockbook/common.gitcommit=$(git describe --always --dirty) -X github.com/trezor/blockbook/common.buildtime=$(date --iso-8601=seconds)" \
    && strip blockbook \
    && ./contrib/scripts/build-blockchaincfg.sh monacoin

FROM debian:buster-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /blockbook/config \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y libsnappy1v5 libzmq5

COPY --from=build /home/blockbook/blockbook /blockbook/
COPY --from=build /home/blockbook/build/blockchaincfg.json /blockbook/config/
COPY --from=build /home/blockbook/static/ /blockbook/static/

WORKDIR /blockbook

COPY launch.sh /home/blockbook/

RUN chmod +x /home/blockbook/launch.sh

ENTRYPOINT [ "/home/blockbook/launch.sh" ]

CMD [ "-sync" ]