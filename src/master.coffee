
# STANDARD LIBRARY
{inspect} = require 'util'
cluster   = require 'cluster'
Stream    = require 'stream'

# THIRD PARTIES
{repeat,wait}   = require 'ragtime'
timmy           = require 'timmy'

# LOCAL FILES
Database      = require './database'
Stats         = require './stats'

{P,isFunction,makeId, NB_CORES} = require './common'

debug = (msg) -> 
  if yes
    console.log "#{msg}"

pretty = (obj) -> "#{inspect obj, no, 20, yes}"


class Master extends Stream

  constructor: (options={}) ->
    #console.log "master started with options: "+pretty options

    workersByMachine  = options.workersByMachine  ? NB_CORES
    decimationTrigger = options.decimationTrigger ? 10
    frequency         = options.frequency         ? 1000
    databaseSize      = options.databaseSize      ? 10
    debugInterval     = options.debugInterval     ? 2.sec
    restart_delay     = 500.ms

    # init db
    database = new Database databaseSize

    bootstrap = options.bootstrap ? []

    emit = (key,msg) =>
      @emit key, msg

    log = (msg) ->
      console.log "MASTER: #{msg}"
    # load agents
    log "loading #{bootstrap.length} agents"
    for agent in bootstrap
      database.add agent

    # bind stats to database
    #stats = new Stats database

    spawn = ->
      log "spawning worker"
      worker = cluster.fork()
      send = (msg) -> worker.send JSON.stringify msg

      worker.on 'message', (msg) ->

        #console.log "worker replied: #{msg}"
        msg = JSON.parse msg

        # always forward all messages to the listeners
        emit 'message', msg

        if 'ready' of msg
          #console.log "worker said hello, sending genome"
          agent = database.next()
          if agent?
            log "sending agent program to worker process"
            worker.agent = agent
            send agent
          else
            log "no more agent to send, stopping system"
            for worker in cluster.workers
              worker.destroy()
            process.exit 0

        else if 'fork' of msg
          log "agent want to fork"
          database.record msg.fork

        else if 'die' of msg
          log "agent want to die: #{msg.die}"
          database.remove worker.agent


    # reload workers if necessary
    cluster.on "exit", (worker, code, signal) -> 
      log "worker exited: #{code}"
      wait(restart_delay) -> spawn() 

    i = 0
    while i++ < workersByMachine
      spawn()
    @emit 'ready'

    repeat debugInterval, ->
      g = genome = database.pick()
      return unless g

      # we disable the dsiplay of random samples
      return
      log "random individual:"
      log "  hash:     : #{g.hash}"
      log "  generation: #{g.generation}"
      ###
      console.log "   parent stats:"
      console.log "    forking   : #{g.stats.forking_rate}"
      console.log "    mutation  : #{g.stats.mutation_rate}"
      console.log "    lifespan  : #{g.stats.lifespan_rate}\n"
      ###
      log " general stats:"
      log "  db size: #{database.size()}"
      log "  counter: #{database.counter}"
      log "  oldest : #{database.oldestGeneration()}\n"

module.exports = (args) -> new Master args
