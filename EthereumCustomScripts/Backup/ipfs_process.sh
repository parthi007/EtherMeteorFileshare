#!/bin/bash 
echo "IPFS restarts itself on failure"

screen -X -S ipfs quit

screen -dmS ipfs ipfs daemon

waitfor() {
  curl $1 --connect-timeout 1 -m 1 -s 2>/dev/null > /dev/null
  if [ $? -ne 0 ]; then
    waitfor $1
  fi
}

waitfor "localhost:5001/webui"

echo "IPFS restarts itself on failure"