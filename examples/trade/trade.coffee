#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'

system = new System

  bootstrap: [
    require './default'
  ]

  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10
  
  config: (agent) ->
    
    portfolio: {}
    history: []
    balance: 100000
      
system.start()

