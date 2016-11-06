#!/bin/bash

pushd .

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "this script must be run as root"
    sudo $0 `npm root -g`
    exit
fi

homeDir="/etc/sleepy-server"
scriptFile="$homeDir/sleepy-server.sh"
crontabFile="/etc/crontab"

#copy the files to a more permanent location
echo 'Installing files' $1

stat $homeDir 2> /dev/null || mkdir -p $homeDir
cp $1/sleepy-server/bin/sleepy-server.sh $scriptFile
chmod +x $scriptFile

#add the cron job to monitor for users
if [ -z "`grep $scriptFile $crontabFile`" ]; then
  echo "* * * * * root sh $scriptFile" >> $crontabFile
fi

echo 'Installation successful!'

popd .
