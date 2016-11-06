#!/bin/bash


installDir="/etc/sleepy-server"

user=`cat $installDir/user`
logFile='/var/log/sleepy-server.log'
shutdownDelay="30 minutes"

function log {
  echo "`date`: $1" >> $logFile
}

function checkForActiveUser {
  activeUser=$(who -a | grep $user)
  if [ -n "$activeUser" ]; then
    echo true
  else
    echo false
  fi
}

function scheduleShutdown {
  if [ -e "/var/run/shutdown.pid" ]; then
    log "shutdown already scheduled"
  else
    log "shutting down in $shutdownDelay"
    shutdown -h $shutdownDelay
  fi
}

function cancelShutdown {
  if [ -e "/var/run/shutdown.pid" ]; then
    log 'canceling shutdown: because user is active'
    shutdown -c
  fi
}

if [ $(checkForActiveUser) = "true" ]; then
  log "user is active"
  cancelShutdown
  exit
else
  scheduleShutdown
fi
