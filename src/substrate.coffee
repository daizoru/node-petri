master = require './master/master'
morker = require './worker/worker'
common = require './common'

exports.NB_CORES = common.NB_CORES
exports.master = master
exports.worker = worker

exports.start = start = (options={}) ->  # command line mode
  console.log "START"
  cluster = require 'cluster'
  timmy   = require 'timmy'

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


# check auto-start
exec = process.argv[1]
if 'substrate' is exec[-9..] or 'substrate.js' is exec[-11..]
  console.log "used in command-line"
  start()
else
  console.log "used as a library"
