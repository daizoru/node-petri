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
    #sum: 0
    #avg: 0
    count: 0

System

  bootstrap: [ 
    require './copycat' 
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

  # you can overload the default behavior
  onData: (agent, data) ->
    k = 'errorRate'
    value = data[k]
    console.log "value: #{value}"
    shared[k].count++
    shared[k].min = Math.min value, shared[k].min
    shared[k].max = Math.max value, shared[k].max
    #shared[k].sum += value
    #shared[k].avg = shared[k].sum / shared[k].count 
