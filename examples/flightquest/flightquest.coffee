#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'

# initialize the multi-models, multi-agents system
System

  bootstrap: [
      #require "./model1"
      require "./model2"
    ]

  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10

  config: (agent) ->
    data:
      training: [
      ]
    updateInterval: 1.sec