#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'

System

  bootstrap: [ require './agent' ]

  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10

  config: (agent) ->
    data:
      training: [
      ]
    updateInterval: 1.sec