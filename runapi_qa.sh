	#!/bin/sh 
Terminaltitle="HealthApp API"
echo -e '\033]2;'$Terminaltitle'\007'
echo "Starting HealthApp api"
cd HealthAppAPI
echo "setting config file to be used as QA"
export NODE_ENV=QA

#In production use the below statement to start node server
#DEBUG=express:* node index.js

#in development, start the server using nodemon, since it restart the node server on code change
DEBUG=express:* nodemon indexV2.js --ignore 'imagesPath/*' --ignore 'downloads/*'

#In development,To use realtime debugger Node-inspecter (the p parameter is the optional debugging port number)
#node-debug --web-host 127.0.0.2 --p 5860 indexV2.js 