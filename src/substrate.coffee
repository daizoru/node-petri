
# STANDARD LIBRARY
{inspect} = require 'util'
cluster = require 'cluster'

# THIRD PARTIES
Master = require './master'
Worker = require './worker'

common   = require './common'

errors   = require './errors'
Stats    = require './stats'

exports.NB_CORES = common.NB_CORES
exports.common   = common

exports.Stats    = Stats
exports.errors   = errors

class System
  constructor: (options={}) ->

    if cluster.isMaster
      console.log "IS MASTER"
      master options
    else
      console.log "IS WORKER"
      worker options

exports.System = System