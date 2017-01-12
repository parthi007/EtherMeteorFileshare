#!/bin/sh 
Terminaltitle="Meteor App"
echo -e '\033]2;'$Terminaltitle'\007'
echo "Starting Meteor app"
cd HealthApp
METEOR_PROFILE=1 
METEOR_LOG=debug 
meteor --verbose --port 0.0.0.0:3000
