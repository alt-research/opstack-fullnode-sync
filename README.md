# Opstack Fullnode Synchronization Guide

A simple docker compose script for launching full node for OP Stack chains.

## Recommended Hardware

- 16GB+ RAM
- 2TB SSD (NVME Recommended)
- 100mb/s+ Download

## Installation and Configuration

### Install docker and docker compose

Please follow offcial instruction here: https://docs.docker.com/engine/install/

### Clone the Repository

```sh
git clone https://github.com/alt-research/opstack-fullnode-sync
cd opstack-fullnode-sync
```

### Prepare genesis.json and rollup.json

TODO

### Generate JWT file

```shell
openssl rand -hex 32 > jwt.txt
```

### Copy node.env.example to node.env

Make a copy of `node.env.example` named `node.env`.

```sh
cp node.env.example node.env
```


### Copy l2.env.example to l2.env

Make a copy of `l2.env.example` named `l2.env`.

```sh
cp l2.env.example l2.env
```

Open `node.env` and `l2.env` with your editor of choice, and update:

1. SEQUENCER_HTTP
2. BOOTNODES
3. L1_RPC
4. P2P_ADDR

## Operating the Node

### Start

```sh
docker compose up -d
```

### View logs

logs for op-node

```sh
docker compose logs -f op-node
```

logs for op-l2 geth node

```sh
docker compose logs -f l2
```

### Sanity Test

#### check sync status

```sh
curl --location 'localhost:8545' \
--header 'Content-Type: application/json' \
--data '{
  "jsonrpc": "2.0",
  "method": "eth_syncing",
  "param": [],
  "id": 2
}'
```

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "currentBlock": "0x7d0f5",
    "healedBytecodeBytes": "0x0",
    "healedBytecodes": "0x0",
    "healedTrienodeBytes": "0x9d12b",
    "healedTrienodes": "0x1197",
    "healingBytecode": "0x0",
    "healingTrienodes": "0x0",
    "highestBlock": "0xd8674",
    "startingBlock": "0x6a58f",
    "syncedAccountBytes": "0xb1801",
    "syncedAccounts": "0x9c1",
    "syncedBytecodeBytes": "0x51375",
    "syncedBytecodes": "0x34",
    "syncedStorage": "0x2b24",
    "syncedStorageBytes": "0x225f7a"
  }
}

```

#### check after syncing

```sh
curl --location 'localhost:8545' \
--header 'Content-Type: application/json' \
--data '{
  "jsonrpc": "2.0",
  "method": "eth_blockNumber",
  "id": 2
}'
```

should return something like: 

```sh
{
    "jsonrpc": "2.0",
    "id": 2,
    "result": "0x2139"
}
```

### Stop

```sh
docker compose down
```

### Clear storage

```sh
docker volume ls
# you will see
local     opstack-fullnode-sync_l2_data
local     opstack-fullnode-sync_node

# delete the volume
docker volume rm opstack-fullnode-sync_l2_data
docker volume rm opstack-fullnode-sync_node
```

Will shut down the node without wiping any volumes.
You can safely run this command and then restart the node again.