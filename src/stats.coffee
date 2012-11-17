{inspect} = require 'util'
{puts} = require 'sys'

class module.exports
  constructor: (@root, @values=['energy']) ->

    @_ =
      pool_size: 0

    for value in @values
      @_[value] =
        min: undefined
        max: undefined
        avg: undefined

  toString: =>
    inspect @_, no, 20, yes

  getSnapshot: => @_
    
  begin: =>
    puts "updating stats.."
    @_.pool_size = @root.workers.length
    for value in @values
      @_[value].min = undefined
      @_[value].max = undefined
      @_[value].avg = undefined

  measure: (worker) =>
    for value in @values
      sb = @_[value]
      ab = worker[value]
      sb.min = if sb.min? then (if ab < sb.min then ab else sb.min) else ab
      sb.max = if sb.max? then (if ab > sb.max then ab else sb.max) else ab
  
  end: =>
    for value in @values
      if @_.pool_size then ( @_[value].avg / @_.pool_size ) else 0.0
    puts "stats updated: #{@toString()}"

  update: =>
    @begin()
    @measure worker for worker in @root.workers
    @end()

