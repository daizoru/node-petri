#!usr/bin/env coffee
{inspect} = require "util"
path      = require "path"
os        = require "os"
fs        = require "fs"

{isFunction, makeId, sha1, shuffle, pick} = require './common'

read_file = (f) -> fs.readFileSync input, "utf8"

class module.exports
  constructor: (@max_size=100) ->
    @_ = {}
    @length = 0
    @counter = 0

    @batch = []

  remove  : (g)     => 
    id = g.id ? (Number) g
    delete @_[id]
    
  add: (agent) =>
    src = ""
    dat = for k,v of agent
      if k is 'main'
        dat[k] = src = v.toString()
      else
        dat[k] = v
    dat.generation ?= 0
    dat.hash = sha1 src
    dat.id ?= makeId()

    @record dat

  record  : (g)     => @_[g.id] = g ; @counter++
  size    :         => @keys().length
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
