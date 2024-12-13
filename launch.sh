#!/bin/bash

CFG_FILE=/blockbook/config/blockchaincfg.json

exec ./blockbook -blockchaincfg=/blockbook/config/blockchaincfg.json -datadir=/blockbook/db -workers=${WORKERS:-1} -public=:${BLOCKBOOK_PORT:-9141} -logtostderr "$@"