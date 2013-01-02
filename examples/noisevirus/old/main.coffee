#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'
{P, copy, pretty} = common

shared =
  errorRate:
    min: Infinity
    max: -Infinity
    avg: 0
    count: 0
    history: []

system = System

  bootstrap: [ 
    require './algorithm' 
  ]

  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10
  
  config: (agent) ->
    global:
      gain: 0.05 # the "volume"

    dataset:
      file: 'training/sorrydave.mp3'
      length: 85002
      channel: 0
      sampleRate: 44100

    shared: shared

  # a global function, which compute the best score
  # as a reference, for others to compare to it
system.on 'data', ({agent, msg}) ->

  value = msg.errorRate
  agent.performance = value

  shared.errorRate.history.push value
  shared.errorRate.history.shift() if shared.errorRate.history.length > 5
  
  # let's remove the least performing agent
  console.log "reducing.."
  system.reduce (a,b) ->
    console.log "a: #{pretty a}   b: #{pretty b}"
    b

  console.log "value: #{value}"
  shared.errorRate.count++

  i = 6
  shared.errorRate.avg = (shared.errorRate.history.reduce (a,b) -> i--; (b * i) + a) / 15

  shared.errorRate.min = Math.min shared.errorRate.avg, shared.errorRate.min
  shared.errorRate.max = Math.max shared.errorRate.avg, shared.errorRate.max
  
  # edge cases
  shared.errorRate.avg = 0 unless isFinite shared.errorRate.avg
  shared.errorRate.min = Infinity unless isFinite shared.errorRate.min
  shared.errorRate.max = -Infinity unless isFinite shared.errorRate.max

  #shared[k].sum += value
  #shared[k].avg = shared[k].sum / shared[k].count 
