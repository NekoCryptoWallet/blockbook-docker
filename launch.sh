#!/bin/bash

CFG_FILE=/blockbook/config/blockchaincfg.json

# Loop to restart blockbook if it fails
while true; do
    echo "Starting Blockbook..."
    exec ./blockbook -blockchaincfg=$CFG_FILE -datadir=/blockbook/db -resyncindexperiod=60017 -resyncmempoolperiod=60017 -resyncmempoolperiod=60017 -workers=${WORKERS:-1} -public=:${BLOCKBOOK_PORT:-9149} -logtostderr "$@"
    
    # If ./blockbook fails, wait before restarting
    echo "Blockbook crashed with exit code $?. Restarting in 5 seconds..."
    sleep 5
done
