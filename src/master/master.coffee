cluster       = require 'cluster'

{repeat,wait} = require 'ragtime'
timmy         = require 'timmy'

Database      = require './database'


module.exports = (options={}) ->
  console.log "master started"
  db_size        = options.db_size        ? 10
  nb_cores       = options.nb_cores       ? 1
  sampling_delay = options.sampling_delay ? 2.sec
  restart_delay  = 500.ms

  # init db
  db = new Database db_size
  
  # bootstrap the db - todo, rather load a function?
  #db.load 
  #db.load '0-0.js'

  # helper function to send a genome to some worker
  sendGenome = (worker) ->
    genome = db.next()
    if genome?
      console.log "sending genome"
      worker.genome = genome
      worker.send JSON.stringify {genome}
    else
      console.log "error, no genome to send; retrying later"
      wait(restart_delay) -> sendGenome worker

  runWorker = ->
    console.log "runWorker"
    worker = cluster.fork()
    worker.on 'message', (msg) ->
      console.log "worker replied"
      msg = JSON.parse msg
      sendGenome worker       if 'hello'  of msg
      db.record msg.record    if 'record' of msg # no else, to support batch mode
      db.remove worker.genome if 'die'    of msg
      if 'die' of msg
        console.log "worker died: #{msg.die}"

  # reload workers if necessary
  cluster.on "exit", (worker, code, signal) -> 
    console.log "worker exited: #{code}"
    wait(restart_delay) -> runWorker() 

  # run workers over CPU cores
  console.log "nb_cores: #{nb_cores}"
  [0..nb_cores].map (i) -> runWorker()

  repeat sampling_delay, ->
    g = db.pick()
    return unless g
    console.log "random individual:"
    console.log "  hash:     : #{g.hash}"
    console.log "  generation: #{g.generation}"
    console.log "   parent stats:"
    console.log "    forking   : #{g.stats.forking_rate}"
    console.log "    mutation  : #{g.stats.mutation_rate}"
    console.log "    lifespan  : #{g.stats.lifespan_rate}\n"
    console.log " general stats:"
    console.log "  db size: #{db.size()}"
    console.log "  counter: #{db.counter}"
  console.log "  oldest : #{db.oldestGeneration()}\n"
