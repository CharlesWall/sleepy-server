#!/usr/bin/env coffee

request = require 'request'
Q = require 'q'
net = require 'net'
AWS = require 'aws-sdk'
ec2 = new AWS.EC2 region: 'us-east-1'

query = process.argv[2]

instanceId = query if query.match /^i-.*/
ipAddress = query if query.match /[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/

unless instanceId or ipAddress
  console.error 'wake-instance (ip-address|instance-id)'
  process.exit 1

description = null

establishConnection = (instanceIp) ->
  deferred = Q.defer()
  socket = new net.Socket
  socket.setTimeout 10000
  socket.connect 22, instanceIp
  socket.on 'connect', ->
    console.log 'connection established!'
    deferred.resolve()
  socket.on 'timeout', (event) -> deferred.reject new Error 'timed out trying to connect'
  socket.on 'error', (event) -> deferred.reject event
  return deferred.promise

Q()
  .then ->
    #get instance description
    if instanceId
      params = InstanceIds: [instanceId] if instanceId
    else if ipAddress
      params = Filters: [Name: "ip-address", Values: [ipAddress]]
    Q.ninvoke ec2, 'describeInstances', params
      .then (instanceState) ->
        description = instanceState?.Reservations?[0]?.Instances?[0]
        unless description
          console.error 'instance not found'
          process.exit 1
        instanceId = description.InstanceId
        console.log description
  .then ->
    runState = description.State.Name
    if runState in ['running', 'starting']
      console.log "instance already #{runState}"
    else
      console.log "starting instance #{runState} => starting"
      Q.ninvoke ec2, 'startInstances', InstanceIds: [instanceId]
  .then ->
    instanceIp = description.PublicIpAddress
    retries = 100
    count = 0
    tryToConnect = ->
      console.log "try to connect #{count}..."
      establishConnection instanceIp
        .catch (error) ->
          console.log "Failed to connect: #{error.message}"
          if retries > count++
            tryToConnect()
          else process.exit 1
    tryToConnect()
  .then ->
    process.exit 0
  .catch (error) ->
    console.error error
    process.exit 1
