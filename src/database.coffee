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

    @queue = []

    
  record  : (g)     => @_[g.id] = g ; @length++


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

  add: (agent) =>
    id = agent.id ? makeId()
    src = agent.src ? agent
    generation = agent.generation ? 0
    src = src.toString() if isFunction src
    hash = sha1 src
    @record {id, src, hash, generation}

  remove: (item, onComplete) =>
    work = =>

      id = undefined
      dv = undefined

      # are we doing a trivial search?
      if item.id?
        id = item.id
      else if isString item
        id = item
      else if isFinite item
        id = item.toString()
      #console.log "remove: #{item}  id: #{id} from #{pretty Object.keys @_}"
      # we passed a matching function
      unless id?
        for k,v of @_
          if item k, v
            id = k
            break

      if id?

        delete @_[id]
        #console.log "deleted #{id}. keys are now #{Object.keys @_}"

        @length--

      #console.log "deleted: #{pretty Object.keys @_}"
      r = undefined
      if id?
        r = {}
        r[id] = dv
      if onComplete?
        onComplete r
      else
        r
    if onComplete?
      process.nextTick work
    else
      work()

  reduce: (reducer) => 

    #console.log "keys: #{pretty keys}"
    #([k,@_[k]] for k in keys).reduce r
    a = 0
    for id, agent of @_
      #console.log "k: #{k}"
      item = [id,agent]
      a = reducer a, item
    a
  # pick up next individual in a round

  max: (f) =>
    max = -Infinity
    for id, agent of @_
      value = f agent
      unless value?
        continue
      if value > max
        max = value
    max

  min: (f) =>
    min = Infinity
    for id, agent of @_
      value = f agent
      unless value?
        continue
      if value < min
        min = value
    min

  each: (f) =>
    for id, agent of @_
      f agent
    @

  agents: (cmp) =>
    tmp = []
    for id, agent of @_
      tmp.push agent
    tmp.sort(cmp ? (a, b) -> b.generation - a.generation)
    tmp

  next: =>
    keys = Object.keys @_
    item = @_[pick keys]
    #console.log "item: #{item}  and keys: #{keys}"
    item
    ###
    @_[id] if id of @_

    # update the queue
    queue = for id in @queue
      if id? and id of @_
        id
    @queue = queue

    if @queue.length is 0
      @queue = Object.keys @_
      if @queue.length is 0
        console.log "ok, here the queue is really empty.. returning undefined"
        return undefined

    nextId = @queue.shift()
    unless nextId
      throw new Error "nextId is null"

    nextAgent = @_[nextId]
  
    unless nextAgent?
      throw new Error "next agent is null.. wtf"
    
    nextAgent
    ###

