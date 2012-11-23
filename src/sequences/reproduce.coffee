cluster          = require 'cluster'
{inspect}        = require 'util'
deck             = require 'deck'
{map,wait}       = require 'ragtime'
{mutable,mutate} = require 'evolve'
timmy            = require 'timmy'

#Memory           = require './memory'
{P, makeId, sha1, pick} = require '../common'

->

  console.log "sending hello world"
  outputs hello: 'world'

  # start listening to incoming messages
  inputs (msg) ->
    console.log "master sent us #{inspect msg}"
    genome = msg.genome

    if genome?

      # default values of I/O variables
      mutation_rate = 0.05   
      forking_rate  = 0.60
      lifespan_rate = 0.01

      #  intenal (local) variables
      foo = 0.25  

      # TODO should be the same shit
      eval genome.src # run the evolvable kernel
      compute()

      mutation_rate = Math.abs mutation_rate
      lifespan_rate = Math.abs lifespan_rate
      forking_rate  = Math.abs forking_rate
      
      # eve is not killed until we fully bootstrapped the system
      # maybe it's optional, since there will die after all,
      # and we can achieve the same by stopping forking
      if genome.generation > 0 and Math.random() < lifespan_rate
        outputs die: "end of tree"

      if Math.random() < forking_rate 
        #console.log "cloning"
        evolve.clone
          ratio: mutation_rate
          src: genome.src
          onComplete: (new_src) ->
            #console.log "sending back a new src to master"
            outputs
              record:
                src: new_src
                generation: genome.generation + 1
                id: makeId()
                hash: sha1 new_src
                stats: { mutation_rate, lifespan_rate, forking_rate }
            process.exit 0
      else
        process.exit 0
    else
      err = "error, unknow message: #{inspect msg}"
      console.log err
      process.exit 1

