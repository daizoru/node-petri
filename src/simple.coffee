# STANDARD LIBRARY
{inspect} = require 'util'

# THIRD PARTIES
{wait}    = require 'ragtime'

# LOCAL FILES
Stats     = require './stats'
common    = require './common'
{P,isFunction} = common

debug = (msg) -> 
  if yes
    console.log "#{msg}"

pretty = (obj) -> "#{inspect obj, no, 20, yes}"

class module.exports

  # global (shared) data can be attached to the master
  # this data will be accessible by workers on demand
  # (they call a function in their outputs, and they will get
  # data for the next cycle in their inputs)
  constructor: (options={}) ->

    @connector = options.connector
    @frequency = options.frequency ? 1000
    stats = options.stats ? { energy: (worker) -> worker.energy }

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

    @stats = new Stats @, stats
  
  start: =>

    # better to avoid @ in the loop
  
    frequency  = @frequency
    connector  = @connector

    sync = (f) => wait(@frequency) => @stats.update() ; f()

    iterations = 0
    do _ = => sync =>
      iterations += 1
      debug "iteration ##{iterations}: #{@workers.length} workers remaining"
      @workers = for worker in @workers
        #debug "going to process worker #{worker}"
        debug "preparing input data"
        inputs = connector.input {}, worker
        debug "running kernel on inputs: "+ pretty inputs
        outputs = {}
        try
          outputs = worker.kernel inputs
        catch e1
          debug "killing individual (bad kernel: #{e1})"
          continue
        try
          connector.output @stats, {}, worker, outputs
        catch e2
          debug "killing individual (bad output: #{e2})"
          continue
        worker
  
      _()

  decimate: =>
    debug "stats: #{inspect @stats}"

