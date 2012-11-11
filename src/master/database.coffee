#!usr/bin/env coffee
{inspect} = require "util"
path      = require "path"
os        = require "os"
fs        = require "fs"

{isFunction, makeId, sha1, shuffle, pick} = require '../common'

read_file = (f) -> fs.readFileSync input, "utf8"

class module.exports
  constructor: (@max_size=100) ->
    @_ = {}
    @length = 0
    @counter = 0

    @batch = []

  load: (input) =>
    console.log "importing #{input}"
    src = ""
    id = makeId()
    generation = 0

    if isFunction input
      src = file.toString()
    else
      src  = read_file input
      split = input.split '-'
      g = split[0]
      generation = ((Number) g) if g?
      i = split[1]
      id = ((Number) i) if i?
      
    hash = sha1 src

    @record
      src: src
      id: id
      generation: generation
      hash: hash
      stats: {}

  remove  : (g)   => delete @_[g.id]
  record  : (g)   => @_[g.id] = g ; @counter++
  size    :       => @keys().length
  oldestGeneration: =>
    oldest = 0
    for k,v of @_
      oldest = v.generation if v.generation > oldest
    oldest

  # The decimator should take params,
  # to decimate in priority badly performing individual

  keys: => Object.keys @_

  randomKeys: => shuffle @keys()

  pick: => @_[pick @keys()]

  decimate: =>
    size = @size()
    return if size < @max_size
    to_remove = size - @max_size
    #console.log "to remove: #{to_remove}"

    for k in @randomKeys()[0...to_remove]
      #console.log "removing #{k}"
      delete @_[k]

  # pick up next individual in a round
  next: =>
    #console.log "batch: #{@batch}"
    k = @batch.pop()
    #console.log "next: #{k}"
    if !k? and @size() > 0
      #console.log "end of cycle. size: #{@size()}"
      @decimate()
      k = @randomKeys().pop()


    @_[k]

