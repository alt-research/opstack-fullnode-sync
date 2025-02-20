#!/bin/sh
set -e
# set default value for http_api and ws_api if not exist
if [ -z ${HTTP_API+x} ]; then
    export HTTP_API="web3,eth,txpool,net,engine,debug,miner"
fi

if [ -z ${WS_API+x} ]; then
    export WS_API="web3,eth,txpool,net,engine,debug,miner"
fi

# In newer version, we need to specify the static nodes in the config file
# with "StaticNodes" instead of using the "--bootnodes" flag.
# ref: https://github.com/ethereum/go-ethereum/issues/31208
cat > /data/config.toml <<EOF
[Node.P2P]
    StaticNodes = ${GETH_STATICNODES}
EOF
echo "geth p2p bootnodes:"
cat /data/config.toml

# do geth init if datadir is empty
if [ ! -d "/data/geth" ]; then
    echo "Initializing geth datadir"
    wget -O /data/genesis.json $GENESIS_URL
    geth init --state.scheme=hash --datadir=/data /data/genesis.json
else
    echo "geth datadir already initialized, skipping..."
fi

exec geth \
    --datadir=/data \
    --rollup.disabletxpoolgossip=true \
    --rollup.sequencerhttp=$SEQUENCER_HTTP \
    --http \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.addr=0.0.0.0 \
    --http.api=$HTTP_API \
    --ws \
    --ws.addr=0.0.0.0 \
    --ws.api=$WS_API \
    --authrpc.addr=0.0.0.0 \
    --authrpc.vhosts="*" \
    --authrpc.port=8551 \
    --authrpc.jwtsecret=/jwt.txt \
    --metrics \
    --metrics.port=6060 \
    --metrics.addr="0.0.0.0" \
    --syncmode=$SYNC_MODE \
    --gcmode=$GC_MODE \
    --config=/data/config.toml