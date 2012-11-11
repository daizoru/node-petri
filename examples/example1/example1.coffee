cluster = require 'cluster'
timmy = require 'timmy'
substrate = require 'substrate'

substrate.start

  master:
    db_size: 100                 # max number of DNAs stored in DB
    nb_cores: substrate.NB_CORES # you should leave some to the OS
    sampling_delay: 2.sec        # log some stats every N times - for debug

  worker:
    size: 10                     # memory size
    max_iterations: 2            # max iterations - for debug
    update_frequency: 1.sec      # update frequency - for debug

