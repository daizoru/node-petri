{inspect} = require 'util'
{puts} = require 'sys'

class module.exports
  constructor: (@root) ->

    @_ =
      pool_size: 0
      balance:
        min: undefined
        max: undefined
        avg: undefined

  toString: =>
    inspect @_, no, 20, yes

  getSnapshot: => @_
    
  begin: =>
      puts "updating stats.."
      @_.pool_size = @root.workers.length
      @_.energy.min = undefined
      @_.energy.max = undefined
      @_.energy.avg = undefined

  measure: (worker) =>
    # energy
    sb = @_.energy
    ab = worker.energy
    sb.min = if sb.min? then (if ab < sb.min then ab else sb.min) else ab
    sb.max = if sb.max? then (if ab > sb.max then ab else sb.max) else ab
  
  end: =>
    if @_.pool_size then ( @_.energy.avg / @_.pool_size ) else 0.0
    puts "stats updated: #{@toString()}"

  update: =>
    @begin()
    @measure worker for worker in @root.workers
    @end()

