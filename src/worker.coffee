
cluster          = require 'cluster'
{inspect}        = require 'util'
deck             = require 'deck'
{map,wait}       = require 'ragtime'
{mutable,mutate} = require 'evolve'
timmy            = require 'timmy'

{P, makeId, sha1, pick, pretty} = require './common'

agent = undefined

module.exports = (options={}) ->

  agentConfigurator = options.config 
  logLevel = options.logLevel ? 0

  console.log "WORKER STARTED"
  
  # send a message to the master
  send = (msg) -> process.send JSON.stringify msg
  
  process.on 'message', (msg) -> 

    agentMeta = JSON.parse msg
    console.log "WORKER RECEIVED AGENT FROM MASTER: #{pretty agentMeta}"

    master =
      # not implemented
      'on': (msg) ->
        throw new Error "Not Implemented"

      # agent's event emitter
      'emit': (msg) ->
        console.log "EMIT"
        if 'log' in msg
          level = msg.log.level ? 0
          msg = msg.log.msg ? ''
          if logLevel <= level
            console.log "#{msg}"

        if 'die' in msg 
          console.log "AGENT DIE:"
          # genetic death
          if agentMeta.generation >  0
            send die: "end of tree"

        if 'fork' in msg
          src = msg.fork
          console.log "AGENT FORK"
          send 'fork':
            id: makeId()
            generation: agentMeta.generation + 1
            hash: sha1 src
            src: src

    master.logger =
      alert: (msg) -> master.send log: level: 0, msg: "ALERT #{msg}"
      info : (msg) -> master.send log: level: 1, msg: "INFO #{msg}"
      debug: (msg) -> master.send log: level: 2, msg: "DEBUG #{msg}"
    
    # create an instance of the serialized agent
    config = agentConfigurator agentMeta
    console.log "agent config: #{inspect config, no, 20, yes}"

    console.log "evaluating agent"
    # try
    eval "var Agent = #{agentMeta.src};"
    console.log "created Agent: #{pretty Agent}"
    Agent master, config
    # catch
    # we should catch exception, and report to the master
    # if the exception cannot be catch (fatal error of the V8 VM)
    # the the maximum level of error will be applied by the master
    # and the genome will be removed from the database

  send 'ready': 0