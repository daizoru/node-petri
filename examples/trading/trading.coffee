#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'

{pretty} = common

POOL_SIZE = 6

system = System

  bootstrap: [ require './trader' ]

  workersByMachine: 1 # common.NB_CORES
  
  config: (agent) ->

    agent.performance ?= 0

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

if system.isMaster
  console.log "IS MASTER"

  system.onFork = (agent, onComplete) ->

    console.log "#{system.size()} traders"
    # the pool is full: we start the game of throne
    canBeForked = no
    sorted = system.agents (a, b) -> b.performance - a.performance

    console.log "traders: "
    for trader in sorted
      console.log " - " + trader.id

    # TODO only fork if the performance is great
    canBeForked = yes

    if canBeForked or system.size() <= POOL_SIZE
      onComplete agent
    else
      onComplete()

  system.onDie = (agent, onComplete) ->
    authorize = system.size() > POOL_SIZE
    onComplete authorize