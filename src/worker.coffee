# standard library
cluster           = require 'cluster'

# third parties libs
colors            = require 'colors'

# third parties libs (in-house!)
{mutable,mutate}  = require 'evolve'

{P, makeId, sha1, pick, every, pretty} = require './common'

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

    switch msg.cmd
      when 'spawn'
        agent.sha = msg.sha
        agent.src = msg.src
        agent.name = msg.name
        context =
          emit: emit 
          src: msg.src
          logger:
            failure: (msg) -> emit cmd: 'failure', msg: msg.toString()
            warn   : (msg) -> emit cmd: 'warn', msg: msg.toString()
            success: (msg) -> emit cmd: 'success', msg: msg.toString()
            info   : (msg) -> emit cmd: 'info', msg: msg.toString()
            debug  : (msg) -> emit cmd: 'debug', msg: msg.toString()
        every 3.sec -> emit cmd: 'ping'
        eval "var Agent = #{msg.src};"
        console.log "spawned #{pretty agent.name}"
        #try
        Agent.apply context, [ msg ]
        #catch err
        #  console.log "failed: #{err}"
        #  context.logger.failure "#{err}"
        #  process.exit 2

      else
        for listener in (agent.listeners[msg.cmd] ? [])
          listener()

  emit cmd: 'ready'
