#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'
{P, copy, pretty} = common

shared =
  foo: 0

POOL_SIZE = 3

system = System

  bootstrap: [ 
    require './algorithm' 
  ]

  workersByMachine: 1 # common.NB_CORES
  
  config: (agent) ->

    global:
      gain: 0.05 # the "volume"

    dataset:
      file: 'training/sorrydave.mp3'
      length: 85002
      channel: 0
      sampleRate: 44100

    shared: shared

# called whenever an individual want to send a global message
system.onMsg = (agent, msg) -> 
  agent.errorDelta = msg.errorDelta

  # a global function, which compute the best score
  # as a reference, for others to compare to it
system.onFork = (agent) ->
  console.log "system size: #{system.size()}"
  bestOpponent = if system.size() > 1
    system.min (opponent) -> 
      console.log "agent.id: #{agent.id} opponent.id: #{opponent.id} opponent.errorDelta: #{opponent.errorDelta}"
      if opponent.id isnt agent.id # doesn't count ourselve!
        opponent.errorDelta
      else
        1.0
  else
    1.0
  console.log "errorRate => agent: #{agent.errorDelta}   bestOpponent: #{bestOpponent}"
  isBetter = agent.errorDelta < bestOpponent
  if isBetter
    console.log "our agent is better than the best!"
  else
    console.log "agent is not better than the others.."

  # reproduce if we have no competition
  # if there is competition (system.size > 10) we have to beat
  # at least one individual in the pool
  isBetter or system.size() < POOL_SIZE

# revive agents (stop genetic suicide) if we have less than 10 agents
system.onDie = (agent) ->
  system.size() > POOL_SIZE

