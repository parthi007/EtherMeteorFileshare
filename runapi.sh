	#!/bin/sh 
Terminaltitle="HealthApp API"
echo -e '\033]2;'$Terminaltitle'\007'
echo "Starting HealthApp api"
cd /home/node1_admin/Desktop/HealthAppAPI
echo "setting config file to be used as prod"
export NODE_ENV=prod

#In production use the below statement to start node server (this will log the console output to node1.log)
DEBUG=express:* node index.js >> /home/node1_admin/Desktop/node1.log 2>&1

#in development, start the server using nodemon, since it restart the node server on code change
#DEBUG=express:* nodemon index.js --ignore 'imagesPath/*' --ignore 'downloads/*'

#In development,To use realtime debugger Node-inspecter (the p parameter is the optional debugging port number)
#node-debug --web-host 127.0.0.2 --p 5859 index.js 