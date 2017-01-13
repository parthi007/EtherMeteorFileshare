#!/bin/sh 
Terminaltitle="HealthApp API"
echo -e '\033]2;'$Terminaltitle'\007'
echo "Starting HealthApp api"
cd HealthAppAPI
echo "setting config file to be used as prod"
export NODE_ENV=prod
#In production use the below statement to start node server
#DEBUG=express:* node index.js
#in development, start the server using nodemon, since it restart the node server on code change
DEBUG=express:* nodemon index.js
 
