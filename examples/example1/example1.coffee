cluster = require 'cluster'
timmy = require 'timmy'
substrate = require 'substrate'

substrate.start

  master:
    db_size: 100
    nb_cores: substrate.NB_CORES
    sampling_delay: 2.sec

   worker:
    size: 10
    max_iterations: 2
    update_frequency: 1.sec

