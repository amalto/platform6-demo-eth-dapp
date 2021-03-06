#!/usr/bin/env bash

# This is the command generated by the 'embark blockchain' command.
# One difference though, --rpcvhosts=* option is added to allow talking to the node from within Docker containers.
# Inside a Docker container, you should connect to http://host.docker.internal:8545
geth --networkid=1337 \
     --datadir=.embark/development/datadir \
     --port=30303 \
     --rpc --rpcport=8545 \
     --rpcaddr=localhost \
     --rpccorsdomain=* \
     --ws --wsport=8546 \
     --wsaddr=localhost \
     --wsorigins=* \
     --nodiscover --maxpeers=0 --mine --shh \
     --rpcapi=eth,web3,net,debug,shh \
     --wsapi=eth,web3,net,shh,debug,pubsub,personal \
     --targetgaslimit=8000000 \
     --rpcvhosts=* \
     --dev
