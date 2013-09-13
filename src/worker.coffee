# standard library
cluster           = require 'cluster'

# third parties libs
colors            = require 'colors'

{P, makeId, sha1, pick, every, pretty, log} = require './common'

module.exports = ->

  agent =
    sha: ''
    name: ''
    listeners: {}

  emit = (msg) -> process.send JSON.stringify msg
  
  onEvent = (signalKey, cb) ->
    listeners[signalKey] = (listeners[signalKey] ? []).push cb

  spawned = no
  process.on 'message', (raw) -> 


    msg = JSON.parse raw
    #console.log "msg: #{pretty msg}"
    #console.log "msg.cmd: #{msg.cmd}"
    switch msg.cmd
      when 'die'
        emit cmd: 'warn', msg: 'master asked me to die'
        process.exit -1

      when 'spawn'
        #console.log "spawning.."
        for k,v of msg.agent
          continue if k is 'listeners'
          agent[k] = v

        unless agent.src
          emit cms: 'failure', msg: "no src found in params passed ot the spawn()"
          process.exit -1
        
        
        # let's see if the user is trying to load a constant (immutable) module
        try
          loaded = require agent.src
          if loaded
            agent.src = loaded.toString()
          else
            log "loaded a module, but it is empty"

        catch err
          log "this is not a module"
        #agent.sha = msg.agent.sha
        #agent.src = msg.agent.src
        #agent.name = msg.agent.name
        #agent.slot = msg.agent.slot

        context =
          emit: emit 
          src: agent.src
          logger:
            failure: (msg) -> emit cmd: 'failure', msg: msg.toString()
            warn   : (msg) -> emit cmd: 'warn', msg: msg.toString()
            success: (msg) -> emit cmd: 'success', msg: msg.toString()
            info   : (msg) -> emit cmd: 'info', msg: msg.toString()
            debug  : (msg) -> emit cmd: 'debug', msg: msg.toString()
        every 3.sec -> emit cmd: 'ping'
        eval "var Agent = #{agent.src};"
        console.log "spawned #{pretty agent.name}"
        #try
        Agent.apply context, [msg.params]
        #catch err
        #  console.log "failed: #{err}"
        #  context.logger.failure "#{err}"
        #  process.exit 2

      else
        for listener in (agent.listeners[msg.cmd] ? [])
          listener()

  emit cmd: 'ready'
