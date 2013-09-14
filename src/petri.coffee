
# STANDARD LIBRARY
cluster = require 'cluster'

# OUR LIBRARY
Master = require './master'
Worker = require './worker'

exports.common = require './common'

exports.Petri = (options={}) ->
  if cluster.isMaster then Master(opts) else Worker()

exports.isMaster = cluster.isMaster
