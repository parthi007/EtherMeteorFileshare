#!/bin/bash 
echo "Starting Ethereum CustomGenesis"

cd ~/LocalGeth/go-ethereum/build/bin/

echo "Current working directory"
echo $PWD

#geth --identity "DellBCPN2" --datadir="/home/node1_admin/data/Blockchain/DataDir" init "/home/node1_admin/Desktop/EthereumCustomScripts/CustomGenesis.json" console


#start with zero gasprice
/home/node1_admin/LocalGeth/go-ethereum/build/bin/geth --identity "DellBCPN4" --datadir="/home/node1_admin/blockchaindata/DataDir16" --gasprice "0" --targetgaslimit "500000000000" init "/home/node1_admin/Desktop/EthereumCustomScripts/CustomGenesis.json" console