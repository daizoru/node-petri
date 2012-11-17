{inspect} = require 'util'
{puts} = require 'sys'

Stats = require './stats'
common = require './common'

{wait} = require "ragtime"

{P,isFunction} = common

class module.exports

  # global (shared) data can be attached to the master
  # this data will be accessible by workers on demand
  # (they call a function in their outputs, and they will get
  # data for the next cycle in their inputs)
  constructor: (options={}) ->

    @input     = options.input     ? ->
    @output    = options.output    ? ->
    @frequency = options.frequency ? 1000

    @workers = []
    if options.workers?
      _workers = options.workers
      _workers = _workers() if isFunction _workers
      @workers = for worker in _workers
        data =
          kernel: ->
        for k, v of worker
          if k is 'kernel'
            data.kernel = if isFunction v then v else eval v
          else
            data[k] = v
        data

    @stats = new Stats @
  
  start: =>

    # better to avoid @ in the loop
  
    frequency  = @frequency
    inputFunc  = @input
    outputFunc = @output

    sync = (f) => wait(@frequency) => @stats.update() ; f()

    iterations = 0
    do _ = => sync =>
      iterations += 1
      puts "iteration ##{iterations}: #{@workers.length} workers remaining"
      @workers = for worker in @workers
        #puts "going to process worker #{worker}"
        puts "preparing input data"
        inputs = inputFunc {}, worker
        puts "running kernel + outputs"
        outputs = {}
        try
          outputs = worker.kernel inputs
        catch e1
          puts "killing individual (bad kernel: #{e1})"
          continue
        try
          outputFunc @stats, {}, worker, outputs
        catch e2
          puts "killing individual (bad output: #{e2})"
          continue
        worker
  
      _()

  decimate: =>
    console.log "stats: #{inspect @stats}"

