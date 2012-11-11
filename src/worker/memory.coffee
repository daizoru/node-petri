

calloc = (N, f = -> 0) -> {inputs: [], value: f()} for i in [0...N]
    
class module.exports

  constructor: (@max_size) ->
  
    @_ = calloc @max_size, -> Math.random()

  pick: => pick @_
  
  get: (i) => @_[i]

  # obsolete?
  randindex: => Math.round(Math.random() * (@memory.length - 1))
  