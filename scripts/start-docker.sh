#!/bin/bash

echo "prepare genesis: Run validate-genesis to ensure everything worked and that the genesis file is setup correctly"
./fury validate-genesis --home /fury

echo "starting fury node $ID in background ..."
./fury start \
--home /fury \
--keyring-backend test

echo "started fury node"
tail -f /dev/null