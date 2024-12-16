#!/bin/bash

CFG_FILE=/explorer/go/src/PIVX-BlockExplorer/blockchain_cfg.json

# Loop to restart blockbook if it fails
while true; do
    echo "Starting Blockbook..."
    ./bin/blockbook -blockchaincfg=$CFG_FILE -datadir=/explorer/go/src/PIVX-BlockExplorer/db -resyncindexperiod=60017 -resyncmempoolperiod=60017 -resyncmempoolperiod=60017 -workers=${WORKERS:-1} -public=:${BLOCKBOOK_PORT:-9141} -logtostderr "$@"
    
    # If ./blockbook fails, wait before restarting
    echo "Blockbook crashed with exit code $?. Restarting in 5 seconds..."
    sleep 5
done
