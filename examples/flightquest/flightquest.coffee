#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'

System

  bootstrap: [ require "./model" ]
  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10

  config: (agent) ->
    flights: [
      'DELTA-9196'
    ]
