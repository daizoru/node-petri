evolve = require 'evolve'

common = require './common'

master = require './master/master'
worker = require './worker/worker'
Simple = require './simple'
errors = require './errors'
Stats = require './stats'

exports.NB_CORES = common.NB_CORES
exports.common = common
exports.master = master
exports.worker = worker

exports.Simple = Simple
exports.Stats = Stats
exports.errors = errors
exports.evolve = evolve

exports.start = start = (options={}) ->  # command line mode
  console.log "START"
  cluster = require 'cluster'
  require 'timmy'

  if cluster.isMaster
    console.log "IS MASTER"
    conf = options.master ? {}
    master 
      db_size        : conf.db_size          ? 100
      nb_cores       : conf.nb_cores         ? common.NB_CORES
      sampling_delay : conf.sampling_delay   ? 2.sec

  else
    console.log "IS WORKER"
    conf = options.worker ? {}
    worker
      size             : conf.size             ? 10
      max_iterations   : conf.max_iterations   ? 2
      update_frequency : conf.update_frequency ? 1.sec
      main: ->
   

# detect when run in command-line
exec = process.argv[1]
if 'substrate' is exec[-9..] or 'substrate.js' is exec[-11..]
  start()