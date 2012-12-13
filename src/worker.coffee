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

agent = undefined

module.exports = (options={}) ->

  agentConfigurator = options.config 

  logLevel = options.logLevel ? 0

  # log = (msg) -> console.log "(WORKER #{process.pid}) #{msg}"
  #log = (msg) -> console.log "#{msg}"
  #console.log "Worker #{process.pid} started".yellow
  
  # send a message to the master
  send = (msg) -> process.send JSON.stringify msg
  
  process.on 'message', (msg) -> 

    agentMeta = JSON.parse msg
    #log "WORKER RECEIVED AGENT FROM MASTER: #{pretty agentMeta}"
    #agentName = "#{agentMeta.id}"[...6] + ".." + "#{agentMeta.id}"[-6..]
    agentName = "#{agentMeta.id}"[-8..]

    log = (msg) -> console.log "    Agent #{agentName}: #{msg}"
    master =

      # agent's event emitter
      send: (msg) ->
        if 'log' of msg
          level = msg.log.level ? 0
          logmsg = msg.log.msg ? ''
          if logLevel <= level
            log "#{logmsg}"
          # we don't actually send the log

        else if 'die' of msg 
            log "DIE".red
          # genetic death
          if agentMeta.generation >  0
            send die: "end of tree"

        else if 'fork' of msg
          src = msg.fork
          log "Forking agent..".yellow
          send 'fork':
            id: makeId()
            generation: agentMeta.generation + 1
            hash: sha1 src
            src: src
        else
          #log "forwarding unknow message to master: #{pretty msg}"
          send msg

    master.logger =
      failure: (msg) -> master.send log: level: 0, msg: "#{msg}".red
      alert  : (msg) -> master.send log: level: 1, msg: "#{msg}".yellow
      success: (msg) -> master.send log: level: 2, msg: "#{msg}".green
      info   : (msg) -> master.send log: level: 2, msg: "#{msg}"
      debug  : (msg) -> master.send log: level: 3, msg: "#{msg}".grey
    
    # create an instance of the serialized agent
    config = agentConfigurator agentMeta
    #console.log "agent config: #{inspect config, no, 20, yes}"

    eval "var Agent = #{agentMeta.src};"
    #console.log "created Agent: #{pretty Agent}"

    Agent master, agentMeta.src, config

    # we should catch exception, and report to the master
    # if the exception cannot be catch (fatal error of the V8 VM)
    # the the maximum level of error will be applied by the master
    # and the genome will be removed from the database

    # meanwhile, we also send an heartbeat to the master
    # of no heartbeat are heard for 20 secs, we should kill the worker
    repeat 5000, -> send 'heartbeat': 'heartbeat'

  send 'ready': 0

  'on': (key) -> # workers can't be listened to