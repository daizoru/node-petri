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
        console.log "worker: spawning"
        agent.sha = sha1 msg.src
        agent.src = msg.src
        agent.name = "#{agent.sha}"[-8..]
        context = {}
        context.emit = emit 
        context.logger =
          failure: (msg) -> context.emit cmd: 'log', level: 0, msg: "#{msg}".red
          warn   : (msg) -> context.emit cmd: 'log', level: 1, msg: "#{msg}".yellow
          success: (msg) -> context.emit cmd: 'log', level: 2, msg: "#{msg}".green
          info   : (msg) -> context.emit cmd: 'log', level: 2, msg: "#{msg}"
          debug  : (msg) -> context.emit cmd: 'log', level: 3, msg: "#{msg}".grey
        every 5.sec -> emit cmd: 'ping'
        eval "var Agent = #{msg.src};"
        #localLog "spawned agent #{pretty agentMeta.name}, gen #{pretty agentMeta.generation}"
        Agent.apply context, [ msg ]

      else
        for listener in (agent.listeners[msg.cmd] ? [])
          listener()

  emit cmd: 'ready'
