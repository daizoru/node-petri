# standard library
cluster           = require 'cluster'
{inspect}         = require 'util'

# third parties libs
colors            = require 'colors'
deck              = require 'deck'

# third parties libs (in-house!)
{map,wait,repeat} = require 'ragtime'
{mutable,mutate}  = require 'evolve'
timmy             = require 'timmy'

{P, makeId, sha1, pick, pretty} = require './common'

module.exports = ->

  
  # log = (msg) -> console.log "(WORKER #{process.pid}) #{msg}"
  #log = (msg) -> console.log "#{msg}"
  #console.log "Worker #{process.pid} started".yellow
  
  # send a message to the master
  emit = (msg) -> process.send JSON.stringify msg
  
  process.on 'message', (msg) -> 

    agentMeta = JSON.parse msg

    agentName = agentMeta.name
    config = agentMeta.config

    logLevel = config.logLevel ? 0
    preserveGeneration = config.preserveGeneration ? 0

    localLog = (msg) -> console.log " #{agentName}: #{msg}"
    #log "WORKER RECEIVED AGENT FROM MASTER: #{pretty agentMeta.name}, gen #{pretty agentMeta.generation}"

    context =
      source: agentMeta.src

      energy: 100

      # agent's event emitter
      emit: (msg) ->
        #console.log "SEND #{pretty msg}"
        if msg.log?
          level = msg.log.level ? 0
          logmsg = msg.log.msg ? ''
          if logLevel <= level
            localLog "#{logmsg}"
          # we don't actually send the log

        if msg.die?
          localLog "sending die".red
          # by default, we don't kill the N first generations
          if agentMeta.generation > preserveGeneration
            localLog "sending die...."
            emit die: "die"

        if msg.fork?

          #log "sending fork".yellow
          packet =
            id: makeId()
            generation: agentMeta.generation + 1
            hash: sha1 msg.fork.src
            src: msg.fork.src

          # copy user-defined attributes
          for k, v of msg.fork
            continue if k is 'src'
            packet[k] = v



          emit fork: packet

        else
          #log "forwarding unknow message to master: #{pretty msg}"
          emit msg

    


    # execute an energy transfert
    context.transfert = (amount) ->

      # don't consume when no more energy
      return no if (amount < 0) and (amount > context.energy)
      context.energy += amount
      yes

    context.logger =
      failure: (msg) -> context.emit log: level: 0, msg: "#{msg}".red
      alert  : (msg) -> context.emit log: level: 1, msg: "#{msg}".yellow
      success: (msg) -> context.emit log: level: 2, msg: "#{msg}".green
      info   : (msg) -> context.emit log: level: 2, msg: "#{msg}"
      debug  : (msg) -> context.emit log: level: 3, msg: "#{msg}".grey
    



    # create an instance of the serialized agent

    #console.log "agent config: #{inspect config, no, 20, yes}"

    # another magic trick
    eval "var Agent = #{agentMeta.src};"

    localLog "spawned agent #{pretty agentMeta.name}, gen #{pretty agentMeta.generation}"
   
    # the grand finale
    Agent.apply context, [ config ]

    # we should catch exception, and report to the master
    # if the exception cannot be catch (fatal error of the V8 VM)
    # the the maximum level of error will be applied by the master
    # and the genome will be removed from the database

    # meanwhile, we also send an heartbeat to the master
    # of no heartbeat are heard for 20 secs, we should kill the worker
    repeat 5000, -> emit 'heartbeat': 'heartbeat'

  emit 'ready': 0

  'on': (key) -> # workers can't be listened to
  