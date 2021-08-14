#!/bin/sh
if [ ! -z $timezone ]; then
  ln -s /usr/share/zoneinfo/$timezone /etc/localtime
else
  echo "timezone environment variable is not set"
fi 
java -jar  /JavaPrograms/CTP/Runner.jar & wait ${!}
