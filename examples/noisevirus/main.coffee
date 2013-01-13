#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
baudio           = require 'baudio'
timmy            = require 'timmy'
{System, common} = require 'substrate'
{wait}           = require 'ragtime'
{P, copy, pretty, round} = common

# play back a soundwave, using a gain (for volume)
# when finished, onComplete is called

POOL_SIZE = 6

system = System

  bootstrap: [ 
    require './algorithm' 
  ]

  workersByMachine: 5 # common.NB_CORES
  
  config: (agent) ->

    # DYNAMIC PROPERTIES
    agent.errorDelta ?= 1.0 # default error delta is 1.0
 
    playback: no

    dataset:
      file: 'training/sorrydave.mp3'
      length: 85002
      channel: 0
      stereo: no
      sampleRate: 44100

    preserveGeneration: 0 # initial "eve" generation cannot die

if system.isMaster

  console.log "IS MASTER"

  # STATIC PARAMETERS
  monitor = gain: 0.05 # the "volume"
  sample = undefined

  playBack = (wave, gain, onComplete, startAt = 0) ->
    cb = no
    f = (t) ->
      if !cb and wave.length is (startAt + 1)
        cb = yes
        onComplete()
        return
      wave[startAt++] * gain
    b = baudio()
    b.push(f)
    b.play()

  do listen = ->
    if sample?
      console.log "trying to playback!"
      playBack sample, monitor.gain, ->
        wait(2000) listen
    else
      wait(100) listen

  system.onFork = (agent, onComplete) ->

    # the pool is full: we start the game of throne
    canBeForked = no
    sorted = system.agents (a, b) -> a.errorDelta - b.errorDelta
    if sorted[0]?.wave?
      sample = sorted[0].wave

    console.log "#{agent.id}: #{agent.errorDelta}"
    for opponent in sorted
      console.log "  - #{opponent.id}: #{opponent.errorDelta}"
      if agent.errorDelta < opponent.errorDelta
        console.log "agent #{agent.id} better than #{opponent.id} (#{agent.errorDelta} <= #{opponent.errorDelta}) (pool: #{system.size()})".green
        canBeForked = yes
        system.remove opponent
        break

    if canBeForked or system.size() <= POOL_SIZE
      onComplete agent
    else
      onComplete()

  # revive agents (stop genetic suicide) if we have less than 10 agents
  system.onDie = (agent, onComplete) -> 
    authorize = system.size() > POOL_SIZE
    #unless authorize
    #  console.log "refusing death (size: #{system.size()} > POOL_SIZE: #{POOL_SIZE})"
    onComplete authorize


