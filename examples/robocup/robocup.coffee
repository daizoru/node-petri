#!/usr/bin/env coffee

# STANDARD LIB
{inspect} = require 'util'

# THIRD PARTIES
timmy    = require 'timmy'
substrate = require 'substrate'

system = new substrate.System
  bootstrap: [ 
    require './default'
  ]
  workersByMachine: 1 # substrate.common.NB_CORES
  decimationTrigger: 10

  config: (agent) ->
    server:
      host: 'localhost'
      port: 3100
    game:
      scene: 'rsg/agent/nao/nao.rsg'
      team  : 'Daizoru'
      number: 0
    engine:
      updateInterval: 1.sec
      journalSize: 50
      journal: []

system.start()