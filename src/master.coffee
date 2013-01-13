
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

{P,isFunction,makeId, NB_CORES, pretty} = require './common'

debug = (msg) -> 
  if yes
    console.log "#{msg}"

class Master extends Stream

  constructor: (options={}) ->
    #console.log "master started with options: "+pretty options

    workersByMachine   = @workersByMachine   = options.workersByMachine  ? NB_CORES
    databaseSize       = @databaseSize       = options.databaseSize      ? 10
    debugInterval      = @debugInterval      = options.debugInterval     ? 2.sec
    maxGenerations     = @maxGenerations     = options.maxGenerations    ? Infinity
    logLevel           = @logLevel           = options.logLevel          ? 0
    stopIfEmpty        = @stopIfEmpty        = options.stopIfEmpty       ? yes

    agentConfigurator  = options.config                                  ? -> {}

    restart_delay      = 500.ms
    nbGenerations = 0

    @isMaster = yes
    
    # init db
    database = @database = new Database databaseSize

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

    spawn = =>
      if ++nbGenerations > maxGenerations
        log "max generations reached, stopping system"
        for worker in cluster.workers
          worker.destroy()
        process.exit 0

      #log "spawning worker"
      worker = cluster.fork()
      send = (msg) -> worker.send JSON.stringify msg

      worker.on 'message', (msg) =>

        #console.log "worker replied: #{msg}"
        msg = JSON.parse msg

        # always forward all messages to the listeners
        emit 'message', msg

        if 'ready' of msg
          #console.log "worker said hello, sending genome"

          # dirty way to check if the bootstrap list changed
          # database won't add new agent.. probably..

          agent = database.next()

          if agent?
            #log "spawning agent #{agent.id} to ##{worker.id}"
            worker.agent = agent
            agent.name = "#{agent.id}"[-8..]
            agent.config = agentConfigurator agent

            # is logLevel is not defined in the agent config, we try to
            # use the one from options, else 0
            agent.config.logLevel ?= logLevel ? 0

            send agent
          else
            if stopIfEmpty
              log "no more agent to send, stopping system"
              for worker in cluster.workers
                worker.destroy()
              process.exit 0
            else
              log "waiting.."

        if 'fork' of msg
          #log "agent want to fork"
          # TODO create a temporary agent!
          process.nextTick =>
            @onFork msg.fork, (ok) ->
              if ok?
                #log "fork #{msg.fork.id} by agent #{worker.agent.id} is authorized"
                database.record ok
              else
                #log "fork denied"
                return
              return

        if 'die' of msg
          process.nextTick =>
            #log "agent #{agent.id} want to die: #{msg.die}"
            @onDie agent, (granted) ->
              if granted
                #log "death granted for #{agent.id}"
                database.remove agent.id
                #log "database.removed #{agent.id}"
              else
                #log "death denied"
                return
              return

        if 'msg' of msg
          process.nextTick =>
            #log "agent #{agent.id} want to transmit a message: #{msg.msg}"
            # legacy event message system
            @onMsg agent, msg.msg


    # reload workers if necessary
    cluster.on "exit", (worker, code, signal) -> 
      log "worker #{worker.id} exited: " + if code > 0 then "#{code}".red else "#{code}".green
      wait(restart_delay) -> spawn() 

    i = 0
    while i++ < workersByMachine
      spawn()
    @emit 'ready'

  onMsg: (agent, msg) => 
    #console.log "agent #{agent.id} want to transmit a message: #{msg.msg}"
  onFork: (agent, onComplete) => 
    #console.log "agent want to fork"
    onComplete yes
    yes
  onDie: (agent, onComplete) => 
    #console.log "agent #{agent.id} want to die: #{msg.die}"
    onComplete yes

  size: => @database.length

  add: (agent) =>
    @database.add agent

  remove: (agent) =>
    @database.remove agent

  agents: (property) => @database.agents property
  reduce: (f) => @database.reduce f
  max: (f) => @database.max f
  min: (f) => @database.min f
  each: (f) => @database.each f



module.exports = (args) -> new Master args
