#!/bin/sh 
Terminaltitle="HealthApp API"
echo -e '\033]2;'$Terminaltitle'\007'
echo "Starting HealthApp api"
cd HealthAppAPI
echo "setting config file to be used as prod"
export NODE_ENV=prod
DEBUG=express:* node index.js
 
