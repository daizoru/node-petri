#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'

System

  bootstrap: [ require './player' ]

  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10

  config: (agent) ->

    table:
      maxRounds : 10
      chips     : 1000
      blind     : 10
      raise     : 20

    updateInterval: 1.sec
