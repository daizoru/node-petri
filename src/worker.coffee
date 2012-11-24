
cluster          = require 'cluster'
{inspect}        = require 'util'
deck             = require 'deck'
{map,wait}       = require 'ragtime'
{mutable,mutate} = require 'evolve'
timmy            = require 'timmy'

{P, makeId, sha1, pick} = require './common'

agent = undefined

module.exports = (options={}) ->

  Environment = options.environment
  agentConfigurator = options.config 
  logLevel = options.logLevel ? 0

  console.log "WORKER STARTED"
  
  # send a message to the master
  send = (msg) -> process.send JSON.stringify msg
  
  process.on 'message', (msg) -> 
    console.log "WORKER RECEIVED AGENT FROM MASTER: #{msg}"

    agentMeta = JSON.parse msg

    master =
      # not implemented
      'on': (msg) ->
        throw new Error "Not Implemented"

      # agent's event emitter
      emit: (msg) ->
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

    # create an instance of the serialized agent
    config = agentConfigurator agentMeta
    console.log "agent config: #{inspect config, no, 20, yes}"

    console.log "evaluating agent"
    # try
    agent = eval(agentMeta.src) master, agentMeta.options
    # catch
    # we should catch exception, and report to the master
    # if the exception cannot be catch (fatal error of the V8 VM)
    # the the maximum level of error will be applied by the master
    # and the genome will be removed from the database
