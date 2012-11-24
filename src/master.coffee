
# STANDARD LIBRARY
{inspect} = require 'util'
cluster   = require 'cluster'

# THIRD PARTIES
{repeat,wait}   = require 'ragtime'
timmy           = require 'timmy'

# LOCAL FILES
Database      = require './database'
Stats         = require './stats'

{P,isFunction,makeId} = require './common'

debug = (msg) -> 
  if yes
    console.log "#{msg}"

pretty = (obj) -> "#{inspect obj, no, 20, yes}"


module.exports = (options={}) ->
  console.log "master started"

  environment       = options.environment
  workersByMachine  = options.workersByMachine  ? common.NB_CORES
  decimationTrigger = options.decimationTrigger ? 10
  frequency         = options.frequency         ? 1000
  databaseSize      = options.databaseSize      ? 10
  debugInterval     = options.debugInterval     ? 2.sec
  restart_delay     = 500.ms

  # init db
  database = new Database databaseSize
  agents = options.agents ? []

  # load agents
  for agent in agents
    database.add agent

  # bind stats to database
  #stats = new Stats database

  spawn = ->
    console.log "spawn"
    worker = cluster.fork()

    worker.on 'online', ->
      agent = database.next()
      if agent?
        console.log "sending agent"
        worker.agent = agent
        worker.send JSON.stringify agent
      else
        console.log "error, no agent to send. system will shutdown."
        for worker in cluster.workers
          worker.destroy()
        process.exit 0


    worker.on 'message', (msg) ->
      console.log "worker replied: #{msg}"
      msg = JSON.parse msg

      if 'fork' of msg
        database.record msg.fork

      if 'die' of msg
        database.remove worker.agent
        console.log "worker died: #{msg.die}"

  # reload workers if necessary
  cluster.on "exit", (worker, code, signal) -> 
    console.log "worker exited: #{code}"
    wait(restart_delay) -> spawn() 

  i = 0
  while i++ < workersByMachine
    spawn()

  repeat debugInterval, ->
    g = genome = database.pick()
    return unless g
    console.log "random individual:"
    console.log "  hash:     : #{g.hash}"
    console.log "  generation: #{g.generation}"
    console.log "   parent stats:"
    console.log "    forking   : #{g.stats.forking_rate}"
    console.log "    mutation  : #{g.stats.mutation_rate}"
    console.log "    lifespan  : #{g.stats.lifespan_rate}\n"
    console.log " general stats:"
    console.log "  db size: #{database.size()}"
    console.log "  counter: #{database.counter}"
  console.log "  oldest : #{database.oldestGeneration()}\n"

module.exports = Master