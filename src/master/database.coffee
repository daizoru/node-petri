#!usr/bin/env coffee
{inspect} = require "util"
path      = require "path"
os        = require "os"
fs        = require "fs"

deck      = require "deck"

{isFunction, makeId, sha1} = require '../../common'


class Database
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
      src  = fs.readFileSync input, "utf8"
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


  pick    :       => @_[deck.pick Object.keys @_]
  remove  : (g)   => delete @_[g.id]
  record  : (g)   => @_[g.id] = g ; @counter++
  size    :       => Object.keys(@_).length
  oldestGeneration: =>
    oldest = 0
    for k,v of @_
      if v.generation > oldest
        oldest = v.generation
    oldest

  # The decimator should take params,
  # to decimate in priority badly performing individual


  decimate: =>
    size = @size()
    return if size < @max_size
    to_remove = size - @max_size
    #console.log "to remove: #{to_remove}"
    keys = deck.shuffle Object.keys @_
    for k in keys[0...to_remove]
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
      #console.log "new size: #{@size()}"
      @batch = deck.shuffle Object.keys @_
      #console.log "new batch: #{@batch}"
      k = @batch.pop()
      #console.log "new next: #{k}"

    @_[k]

module.exports = Database