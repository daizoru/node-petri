# STANDARD LIBRARY
{inspect} = require 'util'
cluster = require 'cluster'

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

#
#  TODO run all of this code in a sub-worker
# but then we need a broadcast mechanism for
# 
class module.exports

  # global (shared) data can be attached to the master
  # this data will be accessible by agents on demand
  # (they call a function in their outputs, and they will get
  # data for the next cycle in their inputs)
  constructor: (options={}) ->

    @environment = options.environment
    @frequency = options.frequency ? 1000
    stats = options.stats ? { energy: (agent) -> agent.energy }

    @agents = []
    if options.agents?
      _agents = options.agents
      _agents = _agents() if isFunction _agents
      @agents = for agent in _agents
        data =
          update: ->
        for k, v of agent
          if k is 'update'
            data.update = if isFunction v then v else eval v
          else
            data[k] = v
        data

    @stats = new Stats @, stats
  
  start: =>

    # better to avoid @ in the loop
  
    frequency  = @frequency
    environment  = @environment

    sync = (f) => wait(@frequency) => @stats.update() ; f()

    iterations = 0
    do _ = => sync =>
      iterations += 1
      debug "iteration ##{iterations}: #{@agents.length} agents remaining"
      @agents = for agent in @agents
        #debug "going to process agent #{agent}"
        debug "preparing input data"
        inputs = environment.input {}, agent
        debug "running update function on inputs: "+ pretty inputs
        outputs = {}
        try
          outputs = agent.update inputs
        catch e1
          debug "killing agent (bad update function: #{e1})"
          continue
        try
          environment.output @stats, {}, agent, outputs
        catch e2
          debug "killing agent (bad output: #{e2})"
          continue
        agent
  
      _()

  decimate: =>
    debug "stats: #{inspect @stats}"

