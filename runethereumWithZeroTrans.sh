#!/bin/bash

Terminaltitle="Ethereum Private Network"
echo -e '\033]2;'$Terminaltitle'\007'

cd ~/LocalGeth/go-ethereum/build/bin/

echo "Current working directory"
echo $PWD

echo "Starting Ethereum1"

#geth --identity "DellBCPN2" --rpc --rpcaddr "0.0.0.0" --rpcport "8002" --rpccorsdomain "*" --rpcapi "db,http,eth,net,personal,web3" --ipcapi "admin,db,eth,debug,miner,net,shh,txpool,personal,web3" --ipcpath "/home/node1_admin/blockchaindata/.ethereum/geth.ipc"  --port "4003" --maxpeers 5 --nodiscover --solc "/usr/bin/solc" --targetgaslimit "6000000000000" --gasprice "2000" --natspec --networkid 9877 --datadir="/home/node1_admin/blockchaindata/DataDir" --etherbase 0 --unlock 0 --password "/home/node1_admin/data2/customscripts/password.txt" --preload "/home/node1_admin/Desktop/EthereumCustomScripts/run.js"  console

#IPcapi is disabled. the preload script is removed
#geth --identity "DellBCPN2" --rpc --rpcaddr "0.0.0.0" --rpcport "8002" --rpccorsdomain "*" --rpcapi "db,http,eth,net,personal,web3" --port "4003" --gasprice "0"  --maxpeers 5 --nodiscover --networkid 9877 --datadir="/home/node1_admin/blockchaindata/DataDir" --etherbase 0 --unlock 0 --password "/home/node1_admin/data2/customscripts/password.txt"  --preload "/home/node1_admin/Desktop/EthereumCustomScripts/run.js" console

/home/node1_admin/LocalGeth/go-ethereum/build/bin/geth --identity "DellBCPN4" --rpc --rpcaddr "0.0.0.0" --rpcport "8002" --rpccorsdomain "*" --rpcapi "db,http,eth,net,personal,web3" --port "4003" --gasprice "0" --targetgaslimit "500000000000" --maxpeers 5 --nodiscover --networkid 15 --datadir="/home/node1_admin/blockchaindata/DataDir16"  --etherbase 0 --unlock 0 --password "/home/node1_admin/data2/customscripts/password.txt"  --preload "/home/node1_admin/Desktop/EthereumCustomScripts/run.js" console