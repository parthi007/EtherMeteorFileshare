#!/bin/sh 
Terminaltitle="Pfizer Service API"
echo -e '\033]2;'$Terminaltitle'\007'
echo "Starting pfizer api"
cd PfizerAPI  
DEBUG=express:* node index.js
 
