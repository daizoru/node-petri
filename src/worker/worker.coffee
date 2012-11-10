#!/usr/bin/env coffee
{inspect}        = require 'util'
deck             = require 'deck'
{map,wait}       = require 'ragtime'
{mutable,mutate} = require 'evolve'
timmy            = require 'timmy'

{P} = require '../common'


class Worker
  constructor: (options={}) ->

    @size = options.size ? 10
    @max_iterations = options.max_iterations ? 2
    @update_frequency = options.update_frequency ? 1.sec

    memory = []
    for i in [0...@size]
      memory.push
        inputs: []
        value: Math.random()
    @memory = memory

  # this function should be passed to the evolver
  start: =>

    update_frequency = @update_frequency
    max_iterations = @max_iterations
    memory = @memory

    iterations = 0

    randomNode: -> deck.pick memory
    
    randomIndex: -> Math.round(Math.random() * (memory.length - 1))
    
    randomInputRange: -> [0...randomIndex()]

    compute: ->


      console.log "computing.."
      #console.log "memory: #{inspect memory, no, 3, yes}"

      for n in memory
        console.log "computing element"
        # add a new input
        if P mutable 0.20
          console.log "adding a new input"
          n.inputs.push mutable
            input: randomIndex() # TODO should not be *that* random
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
              input_signal = memory[i.input].value
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

    compute()
