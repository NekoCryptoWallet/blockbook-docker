FROM gostartups/golang-rocksdb-zeromq:1511

WORKDIR /home
# Build blockbook
RUN apt install -y libzstd-dev
RUN git clone https://github.com/trezor/blockbook
WORKDIR /home/blockbook

RUN git checkout v0.4.0
# RUN go mod download
RUN go build 
 
# Copy startup scripts
COPY launch.sh /home/blockbook/

RUN chmod +x /home/blockbook/launch.sh

COPY blockchain_cfg.json /blockbook/config/

EXPOSE 9030 9130

ENTRYPOINT $HOME/launch.sh