# STANDARD LIBRARY
{inspect} = require 'util'
cluster = require 'cluster'

Master = require './master'
Worker = require './worker'

class module.exports

  constructor: (options={}) ->

    if cluster.isMaster
      console.log "IS MASTER"
      master options
    else
      console.log "IS WORKER"
      worker options