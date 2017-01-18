	#!/bin/sh 
Terminaltitle="HealthApp API"
echo -e '\033]2;'$Terminaltitle'\007'
echo "Starting HealthApp api"
cd HealthAppAPI
echo "setting config file to be used as prod"
export NODE_ENV=prod
#DEBUG=express:* 
#In production use the below statement to start node server
#DEBUG=express:* node index.js

#in development, start the server using nodemon, since it restart the node server on code change
#nodemon index.js

#To use realtime debugger (the p parameter is the optional debugging port number)
node-debug --web-host 127.0.0.2 --p 5859 index.js 

 
