
# STANDARD LIBRARY
{inspect} = require 'util'
cluster   = require 'cluster'
Stream    = require 'stream'

{pretty, sha1} = require './common'

class Master extends Stream

  constructor: (main) ->

    @isMaster = yes

    emit = (key,msg) => @emit key, msg
    log  = (name, msg) -> console.log "#{name}: #{msg}"

    callbacks =
      onReady: ->
      onExit: ->
      onData: ->

    actions =
      spawn: (agent) =>
        #console.log "debug: spawning.."
        worker = cluster.fork()
        agent.src = agent.src.toString() # automatically converts functions to source code
        agent.sha = sha1 agent.src
        agent.name = "#{agent.sha}"[-8..]
        agent.cmd = 'spawn'
        agent.slot = worker.id
        worker.agent = agent

        worker.on 'message', (raw) =>
          msg = JSON.parse raw
          switch msg.cmd
            when 'ready'
              worker.send JSON.stringify worker.agent
            when 'ping'
              log worker.agent.name, "PING worker is still alive"

            when 'failure'
              log worker.agent.name, "FAILURE #{msg.msg}".red

            when 'warn'
              log worker.agent.name, "WARNING #{msg.msg}".yellow

            when 'success'
              log worker.agent.name, "SUCCESS #{msg.msg}".green

            when 'info'
              log worker.agent.name, "INFO #{msg.msg}"

            when 'debug'
              log worker.agent.name, "DEBUG #{msg.msg}".grey

            else
              reply = (msg) -> worker.send JSON.stringify msg
              callbacks.onData reply, worker.agent, msg
      # broadcast
      broadcast: (msg) ->
        console.log "debug: broadcasting.."
        for id in cluster.workers
          cluster.workers[id].send JSON.stringify msg
          
    cluster.on "exit", (worker, code, signal) -> 
      #log "worker #{worker.id} (#{worker.agent.name}) exited: " + if code > 0 then "#{code}".red else "#{code}".green
      callbacks.onExit worker.agent, code, signal

    main.apply 

      'on': (event, cb) ->
        switch event
          when 'exit'  then callbacks.onExit  = cb
          when 'data'  then callbacks.onData  = cb
          when 'ready' then callbacks.onReady = cb
      
      spawn    : actions.spawn
      broadcast: actions.broadcast

module.exports = (onReady) -> new Master onReady
