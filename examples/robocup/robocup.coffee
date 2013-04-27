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

    server:
      host: 'localhost'
      port: 3100

    game:
      scene: 'rsg/agent/nao/nao.rsg'
      team  : 'Daizoru'
      number: 0

    engine:
      updateInterval: 3.sec