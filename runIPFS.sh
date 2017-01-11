#!/bin/sh 

Terminaltitle="IPFS"
echo -e '\033]2;'$Terminaltitle'\007'

echo "Starting IPFS"
ipfs daemon
