#!/bin/bash

KEY="mykey"
CHAINID="highbury_710-1"
MONIKER="localtestnet"
KEYRING="test"
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
# to trace evm
TRACE="--trace"
# TRACE=""
DIR="${HOME_DIR:-/.nautid}"
GENESIS_FILE="${DIR}/config/genesis.json"

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# Only generate a new genesis.json file if there isn't an existing one
if [[ ! -f "$GENESIS_FILE" ]]; then

  # remove existing daemon and client
  rm -rf ~/.nautid*

  nautid config keyring-backend $KEYRING
  nautid config chain-id $CHAINID

  # if $KEY exists it should be deleted
  nautid keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO

  # Set moniker and chain-id for Ethermint (Moniker can be anything, chain-id must be an integer)
  nautid init $MONIKER --chain-id $CHAINID

  # Change parameter token denominations to axfury
  cat $HOME/.nautid/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="axfury"' > $HOME/.nautid/config/tmp_genesis.json && mv $HOME/.nautid/config/tmp_genesis.json $HOME/.nautid/config/genesis.json
  cat $HOME/.nautid/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="axfury"' > $HOME/.nautid/config/tmp_genesis.json && mv $HOME/.nautid/config/tmp_genesis.json $HOME/.nautid/config/genesis.json
  cat $HOME/.nautid/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="axfury"' > $HOME/.nautid/config/tmp_genesis.json && mv $HOME/.nautid/config/tmp_genesis.json $HOME/.nautid/config/genesis.json
  cat $HOME/.nautid/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="axfury"' > $HOME/.nautid/config/tmp_genesis.json && mv $HOME/.nautid/config/tmp_genesis.json $HOME/.nautid/config/genesis.json

  # increase block time (?)
  cat $HOME/.nautid/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="1000"' > $HOME/.nautid/config/tmp_genesis.json && mv $HOME/.nautid/config/tmp_genesis.json $HOME/.nautid/config/genesis.json

  # Set gas limit in genesis
  cat $HOME/.nautid/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="10000000"' > $HOME/.nautid/config/tmp_genesis.json && mv $HOME/.nautid/config/tmp_genesis.json $HOME/.nautid/config/genesis.json

  # disable produce empty block
  if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.nautid/config/config.toml
    else
      sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.nautid/config/config.toml
  fi

  if [[ $1 == "pending" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.nautid/config/config.toml
        sed -i '' 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.nautid/config/config.toml
        sed -i '' 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.nautid/config/config.toml
        sed -i '' 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.nautid/config/config.toml
        sed -i '' 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.nautid/config/config.toml
        sed -i '' 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.nautid/config/config.toml
        sed -i '' 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.nautid/config/config.toml
        sed -i '' 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.nautid/config/config.toml
        sed -i '' 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.nautid/config/config.toml
    else
        sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.nautid/config/config.toml
        sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.nautid/config/config.toml
        sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.nautid/config/config.toml
        sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.nautid/config/config.toml
        sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.nautid/config/config.toml
        sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.nautid/config/config.toml
        sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.nautid/config/config.toml
        sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.nautid/config/config.toml
        sed -i 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.nautid/config/config.toml
    fi
  fi

  # Allocate genesis accounts (cosmos formatted addresses)
  nautid add-genesis-account $KEY 100000000000000000000000000axfury --keyring-backend $KEYRING

  # Sign genesis transaction
  nautid gentx $KEY 1000000000000000000000axfury --keyring-backend $KEYRING --chain-id $CHAINID

  # Collect genesis tx
  nautid collect-gentxs

  # Run this to ensure everything worked and that the genesis file is setup correctly
  nautid validate-genesis
else
  # We already have a genesis.json file so create an empty priv_validator_state.json
  mkdir $DIR/data
  cat >> $DIR/data/priv_validator_state.json << EOF
  {
    "height": "0",
    "round": 0,
    "step": 0
  }
EOF

# Run this to ensure everything the genesis file is setup correctly
nautid validate-genesis $GENESIS_FILE

fi