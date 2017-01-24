#!/bin/bash 
echo "Starting Ethereum"

geth --identity "DellBCPN1" --datadir="/home/node1_admin/data/Blockchain/DataDir" init "/home/node1_admin/Desktop/EthereumCustomScripts/CustomGenesis.json" console 