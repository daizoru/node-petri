cluster          = require 'cluster'
{inspect}        = require 'util'
deck             = require 'deck'
{map,wait}       = require 'ragtime'
{mutable,mutate} = require 'evolve'
timmy            = require 'timmy'

#Memory           = require './memory'
{P, makeId, sha1, pick} = require '../common'

->
  size = options.size ? 10
  max_iterations = options.max_iterations ? 2
  update_frequency = options.update_frequency ? 1.sec

  malloc = (N, f = -> 0) -> {inputs: [], value: f()} for i in [0...N]

  memory = malloc size, -> 0.0 # Math.random() # 0
 
  mpick = -> pick memory
  mget = (i) -> memory[i]
  mrindex = -> Math.round(Math.random() * (memory.length - 1))
  

  iterations = 0

  compute: ->

    console.log "computing.."
    #console.log "memory: #{inspect memory, no, 3, yes}"

    for n in memory
      console.log "computing element"
      # add a new input
      if P mutable 0.20
        console.log "adding a new input"
        n.inputs.push mutable
          input: mrandindex() # TODO should not be *that* random
          weight: Math.random() * 0.01 + 1.0

      if n.inputs.length

        if P mutable 0.40
          console.log "deleting a random input"
          n.inputs.splice Math.round(Math.random() * n.inputs.length), 1

        # update an input weight
        if P mutable 0.30
          console.log "updating an input weight"
          input = n.inputs[(n.inputs.length - 1) * Math.random()]
          input.weight = mutable input.weight * 1.0

        # compute local state using some inputs
        if P mutable 0.95
          console.log "computing local state"
          n.value = 0
          for i in n.inputs
            input_signal = mget(i.input).value
            n.value += mutable input_signal * i.weight
          if n.inputs.length > 0
            n.value = n.value / n.inputs.length
            

      # done
    console.log "iteration #{++iterations} completed."

    if iterations >= max_iterations 
      console.log "stats: "
      console.log "  #{memory.length} in memory"
      console.log "  #{iterations} iterations"
      return
    else
      wait(update_frequency) -> compute()
