{inspect} = require 'util'
{puts} = require 'sys'

class module.exports
  constructor: (@root, model) ->

    @pool_size = 0
    #console.log "model: #{inspect model}"
    @_ = {}
    for k,v of model
      @_[k] =
        func: v
        values:
          min: +Infinity
          max: -Infinity
          avg: 0
      #console.log "@_[k] = #{inspect @_[k]}"

  toString: =>
    inspect @_, no, 20, yes

  getSnapshot: => @_
    
  begin: =>
    #puts "updating stats.."
    @pool_size = @root.agents.length
    #console.log "begin: @_ is #{inspect @_, no, 20, yes}"
    for k,v of @_
      #console.log "begin: #{inspect v, no, 20, yes}"
      v.values.min = +Infinity
      v.values.max = -Infinity
      v.values.avg = 0

  measure: (agent) =>
    for k,v of @_
      #console.log "measure: #{inspect v, no, 20, yes}"
      sb = v.values
      ab = v.func agent
      sb.min = if sb.min? then (if ab < sb.min then ab else sb.min) else ab
      sb.max = if sb.max? then (if ab > sb.max then ab else sb.max) else ab
      sb.avg = sb.avg + ab
      sb.avg = 0 unless isFinite sb.avg

  end: =>
    for k,v of @_
      #v.values.avg = 0 unless isFinite v.values.avg
      v.values.avg = v.values.avg / @pool_size
      v.values.avg = 0 unless isFinite v.values.avg
    #puts "stats updated: #{@toString()}"

  update: =>
    @begin()
    @measure agent for agent in @root.agents
    @end()
    @_

