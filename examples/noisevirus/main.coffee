#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
baudio           = require 'baudio'
timmy            = require 'timmy'
{System, common} = require 'substrate'

{P, copy, pretty, round} = common


# STATIC PARAMETERS
monitor =
  gain: 0.05 # the "volume"

# play back a soundwave, using a gain (for volume)
# when finished, onComplete is called

POOL_SIZE = 4

system = System

  bootstrap: [ 
    require './algorithm' 
  ]

  workersByMachine: 8 # common.NB_CORES
  
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

playing = no
best = undefined

playBack = (wave, gain, onComplete, startAt = 0) ->
  f = (t) ->
    if wave.length is (startAt + 1)
      onComplete()
      return
    wave[startAt++] * gain
  b = baudio()
  b.push(f)
  b.play()

system.onFork = (agent, onComplete) ->
  size = system.size()

  system.each (candidate) -> 
    if candidate.id isnt agent.id
      if !best? or candidate.errorDelta < best.errorDelta
        best = candidate

  unless best?
    console.log "agent is alone.."
    return onComplete agent

  #console.log "agent: #{round agent.errorDelta}, pool: #{size}"

  isBetter = agent.errorDelta < best.errorDelta
  if isBetter
    console.log "better (#{round agent.errorDelta, 6} < #{round best.errorDelta})".green
  else 
    console.log "searching (#{round agent.errorDelta, 6} > #{round best.errorDelta}) (pool: #{system.size()})".grey

  if isBetter or system.size() < POOL_SIZE
    if agent.wave? and !playing
      playing = yes
      playBack agent.wave, monitor.gain, -> 
        playing = no
        onComplete agent
    else
      onComplete agent
  else
    onComplete()

# revive agents (stop genetic suicide) if we have less than 10 agents
system.onDie = (agent, onComplete) -> 
  onComplete system.size() > POOL_SIZE


