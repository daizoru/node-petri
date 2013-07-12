
# STANDARD LIBRARY
{inspect} = require 'util'
cluster = require 'cluster'

# THIRD PARTIES
Master = require './master'
Worker = require './worker'

common   = require './common'
errors   = require './errors'

exports.NB_CORES = common.NB_CORES
exports.common   = common
exports.errors   = errors

exports.Petri = (options={}) ->
  if cluster.isMaster 
    Master(options) 
  else 
    Worker()

exports.isMaster = cluster.isMaster