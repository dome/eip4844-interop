#!/usr/bin/env bash

set -exu -o pipefail

source /config/values.env

if [ -d  /tmp/validator-output ]; then
    echo "genesis generator already run"
    exit 0
fi

eth2-val-tools keystores\
    --insecure --prysm-pass="prysm"\
    --out-loc=/tmp/validator-output\
    --source-max=64\
    --source-min=0\
    --source-mnemonic="$EL_AND_CL_MNEMONIC"

# reset the GENESIS_TIMESTAMP so the chain starts shortly after
DATE=$(date +%s)
sed -i "s/export GENESIS_TIMESTAMP=.*/export GENESIS_TIMESTAMP=$DATE/" /config/values.env

# this writes generated configs to /data
/work/entrypoint.sh all

# copy configuration used by the test setup
cp -r /data/* /gen-configs

cp -r /tmp/validator-output/keys /lighthouse_data/validators
cp -r /tmp/validator-output/secrets /lighthouse_data/secrets

