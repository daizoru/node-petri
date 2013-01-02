#!usr/bin/env coffee
{inspect} = require "util"
path      = require "path"
os        = require "os"
fs        = require "fs"

{isFunction, isString, makeId, sha1, shuffle, pick, pretty} = require './common'

class module.exports
  constructor: (@max_size=100) ->
    @_ = {}

    @length = 0

    @batch = []

  remove  : (g)     => 
    id = g.id ? (Number) g
    delete @_[id]
    
  add: (agent) =>
    id = agent.id ? makeId()
    src = agent.src ? agent
    generation = agent.generation ? 0
    src = src.toString() if isFunction src
    hash = sha1 src
    @record {id, src, hash, generation}

  record  : (g)     => @_[g.id] = g ; @length++
  size    :         => @keys().length
  oldestGeneration: =>
    oldest = 0
    for k,v of @_
      oldest = v.generation if v.generation > oldest
    oldest

  # The decimator should take params,
  # to decimate in priority badly performing individual

  # up to O(N) search if we search by source code
  contains: (agent) =>
    if g.id?
      if id of @_
        return yes
    else
      hash = sha1 agent
      for k,v of @_
        if g.hash is hash
          return yes
    no
  keys: => Object.keys @_

  randomKeys: => shuffle @keys()

  pick: => @_[pick @keys()]

  remove: (matcher, onComplete) =>
    work = =>


      dk = undefined
      dv = undefined
      if matcher.id?
        dk = matcher.id
      else
        if isString matcher
          dk = matcher
        else
          for k,v of @_
            if matcher k, v
              dk = k
              break
      if dk?
        dv = @_[dk]
        delete @_[dk]
        @length--

      r = undefined
      if dk?
        r = {}
        r[dk] = dv
      if onComplete?
        onComplete r
      else
        r
    if onComplete?
      process.nextTick work
    else
      work()

  reduce: (reducer) => 
    keys = @keys()
    #console.log "keys: #{pretty keys}"
    #([k,@_[k]] for k in keys).reduce r
    a = 0
    for k in keys
      #console.log "k: #{k}"
      item = [k,@_[k]]
      a = reducer a, item
  # pick up next individual in a round

  max: (f) =>
    max = -Infinity
    for k, obj of @_
      value = f obj
      if value > max
        max = value
    max

  min: (f) =>
    min = Infinity
    for k, obj of @_
      value = f obj
      if value < min
        min = value
    min

  next: =>
    if @batch.length is 0
      @batch = Object.keys @_
    @_[@batch.shift()]


