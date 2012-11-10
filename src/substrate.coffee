cluster = require 'cluster'

timmy = require 'timmy'

{nbcores} = require './common'

Worker = require './worker/worker'
Master = require './master/master'

if cluster.isMaster

  master = new Master 
    db_size: 100
    nb_cores: nbcores
    sampling_delay: 2.sec

  master.start()

else
  worker = new Worker
    size: 10
    max_iterations: 2
    update_frequency: 1.sec

  worker.start()

