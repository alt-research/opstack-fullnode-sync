#!/bin/sh
set -e

# Validate mutually exclusive configurations
if [ -n "$NETWORK" ] && ([ -n "$ROLLUP_CONFIG_URL" ] || [ -n "$GENESIS_URL" ]); then
    echo "Error: NETWORK cannot be used together with ROLLUP_CONFIG_URL or GENESIS_URL"
    exit 1
fi

export OP_NODE_L1_ETH_RPC=$L1_RPC
export OP_NODE_L1_RPC_KIND=$L1_RPC_KIND
export OP_NODE_P2P_STATIC=$P2P_STATIC
export OP_NODE_L1_BEACON=$L1_BEACON
export OP_NODE_VERIFIER_L1_CONFS=15
export OP_NODE_SEQUENCER_L1_CONFS=15
export ROLLUP_CONFIG_URL=$ROLLUP_CONFIG_URL

export OP_NODE_ALTDA_DA_SERVICE=$ALTDA_DA_SERVICE
export OP_NODE_ALTDA_ENABLED=$ALTDA_ENABLED
if [ -n "$PLASMA_ENABLED" ] && [ ! -n "$ALTDA_ENABLED" ]; then
    echo "PLASMA_ENABLED is set, ALTDA_ENABLED is not set ,use PLASMA_ENABLED as OP_NODE_ALTDA_ENABLED"
    export OP_NODE_ALTDA_ENABLED=$PLASMA_ENABLED
fi
echo "OP_NODE_ALTDA_ENABLED: $OP_NODE_ALTDA_ENABLED"

export OP_NODE_ALTDA_DA_SERVER=$ALTDA_DA_SERVER
if [ -n "$PLASMA_DA_SERVER" ] && [ ! -n "$ALTDA_DA_SERVER" ]; then
    echo "PLASMA_DA_SERVER is set, ALTDA_DA_SERVER is not set ,use PLASMA_DA_SERVER as OP_NODE_ALTDA_DA_SERVER"
    export OP_NODE_ALTDA_DA_SERVER=$PLASMA_DA_SERVER
fi
echo "OP_NODE_ALTDA_DA_SERVER: $OP_NODE_ALTDA_DA_SERVER"



until nc -z -w 5 geth 8551; do
    echo "Waiting for geth ..."
    sleep 5
done
echo "geth is up"

# Skip rollup.json download when using NETWORK
if [ -n "$NETWORK" ]; then
    echo "Using NETWORK=$NETWORK, skipping rollup.json download"
    # Remove rollup.json if it exists from previous runs
    if [ -f "/data/rollup.json" ]; then
        echo "Removing existing rollup.json"
        rm -f /data/rollup.json
    fi
else
    if [ ! -f "/data/rollup.json" ]; then
        wget -O /data/rollup.json $ROLLUP_CONFIG_URL
    fi
fi

mkdir -p /data/opnode_discovery_db
mkdir -p /data/opnode_peerstore_db
mkdir -p /data/safedb

# Build op-node command
OP_NODE_CMD="exec op-node"

# Add network-specific flag first if NETWORK is set
if [ -n "$NETWORK" ]; then
    OP_NODE_CMD="$OP_NODE_CMD \
    --network=$NETWORK"
else
    OP_NODE_CMD="$OP_NODE_CMD \
    --rollup.config=/data/rollup.json"
fi

# Add L1 beacon flag based on whether L1_BEACON is configured
if [ -n "$L1_BEACON" ]; then
    OP_NODE_CMD="$OP_NODE_CMD \
    --l1.beacon=$L1_BEACON"
else
    OP_NODE_CMD="$OP_NODE_CMD \
    --l1.beacon.ignore"
fi

# Add common flags
OP_NODE_CMD="$OP_NODE_CMD \
    --syncmode=execution-layer \
    --safedb.path=/data/safedb \
    --l1.trustrpc \
    --l2=http://geth:8551 \
    --l2.jwt-secret=/jwt.txt \
    --metrics.enabled \
    --metrics.port=7300 \
    --metrics.addr='0.0.0.0' \
    --rpc.addr=0.0.0.0 \
    --rpc.port=9545 \
    --p2p.listen.ip=0.0.0.0 \
    --p2p.listen.tcp=9003 \
    --p2p.listen.udp=9003 \
    --p2p.discovery.path=/data/opnode_discovery_db \
    --p2p.peerstore.path=/data/opnode_peerstore_db \
    --p2p.priv.path=/data/opnode_p2p_priv.txt"

eval $OP_NODE_CMD
