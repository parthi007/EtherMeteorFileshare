#!/bin/sh 

Terminaltitle="IPFS"
echo -e '\033]2;'$Terminaltitle'\007'

echo "Starting IPFS"
IPFS_FD_MAX=4096 ipfs daemon