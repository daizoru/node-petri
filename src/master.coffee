
# STANDARD LIBRARY
{inspect} = require 'util'
cluster   = require 'cluster'
Stream    = require 'stream'

{pretty, sha1} = require './common'

class Master extends Stream

  constructor: (main) ->

    @isMaster = yes

    emit = (key,msg) => @emit key, msg
    log  = (msg) -> console.log "Petri (master): #{msg}"

    callbacks =
      onReady: ->
      onExit: ->
      onData: ->

    actions =
      spawn: =>
        console.log "debug: spawning.."
        worker = cluster.fork()

        worker.on 'message', (raw) =>
          msg = JSON.parse raw
          switch msg.cmd
            when 'ready'
              process.nextTick -> 
              callbacks.onReady (conf) ->
                console.log "debug: got config"
                worker.src = conf.src # src is a unique 'dna'
                packet = conf
                conf.cmd = 'spawn'
                worker.send JSON.stringify packet
            when 'ping'
              console.log "debug: worker is still alive"
            else
              reply = (msg) -> worker.send JSON.stringify msg
              process.nextTick -> callbacks.onData reply, worker.src, msg
      # broadcast
      broadcast: (msg) ->
        console.log "debug: broadcasting.."
        for id in cluster.workers
          cluster.workers[id].send JSON.stringify msg
          
    cluster.on "exit", (worker, code, signal) -> 
      log "worker #{sha1 worker.src} exited: " + if code > 0 then "#{code}".red else "#{code}".green
      process.nextTick ->
        callbacks.onExit
          worker: worker
          src: worker.src
          code: code
          signal: signal

    main.apply 

      'on': (event, cb) ->
        switch event
          when 'exit'  then callbacks.onExit  = cb
          when 'data'  then callbacks.onData  = cb
          when 'ready' then callbacks.onReady = cb
      
      spawn    : actions.spawn
      broadcast: actions.broadcast

module.exports = (onReady) -> new Master onReady
