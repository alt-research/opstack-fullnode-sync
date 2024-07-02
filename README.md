# Opstack Fullnode Synchronization Guide

A simple docker compose script for launching full node for OP Stack chains.

## Recommended Hardware
- 4 Core
- 16 GB+ RAM
- 1TB SSD (NVME Recommended)
- 100 MB/s+ Download

## Prepare

### Generate JWT file

```shell
openssl rand -hex 32 > jwt.txt
```

### Copy .env.example to .env and update the value

Make a copy of `.env.example` named `.env`.

```sh
cp .env.example .env
# modify .env to your parameters.
```

Or, our team will provide one `.env` file for your rollup directly.

## Operating the Node

### Start

```sh
docker compose --env-file .env up -d
```

### View logs

logs for op node

```sh
docker compose logs -f node
```

logs for op geth

```sh
docker compose logs -f geth
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

if the node is still syncing, you would see:

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

or the syncing has completed:

```json
{"jsonrpc":"2.0","id":2,"result":false}
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

### Reference
- https://docs.optimism.io/builders/node-operators/tutorials/node-from-docker
