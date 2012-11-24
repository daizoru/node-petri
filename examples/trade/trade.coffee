#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'

System

  bootstrap: [ require './model' ]

  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10
  
  config: (agent) ->

    balance: 100000
    
    portfolio: {}
    history: []

    interval: 1.sec

    geekdaq:
      updateInterval: 500
      commissions:
        buy: 0.30
        sell: 0.30
      tickers: [ 
        'PEAR'
        'JS'
        'LISP'
        'PERL'
        'RUBY'
        'NET'
        'JAVA'
        'CAFE'
      ]