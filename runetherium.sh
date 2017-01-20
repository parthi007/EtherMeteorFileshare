#!/bin/bash

Terminaltitle="Etherium Private Network"
echo -e '\033]2;'$Terminaltitle'\007'

echo "Starting Etherium"

geth --identity "DellBCPN1" --rpc --rpcaddr "0.0.0.0" --rpcport "8001" --rpccorsdomain "*" --rpcapi "http,eth,net,web3" --ipcapi "admin,db,eth,debug,miner,net,shh,txpool,personal,web3" --ipcpath "/home/node1_admin/data/Blockchain/.ethereum/geth.ipc"  --port "4002" --maxpeers 5 --nodiscover --solc "/usr/bin/solc" --targetgaslimit "49720693" --gasprice "2000" --natspec --networkid 9876 --datadir="/home/node1_admin/data/Blockchain/DataDir" --etherbase 0 --unlock 0 --password "/home/node1_admin/data/customscripts/password.txt" --preload "/home/node1_admin/data/customscripts/run.js"  console