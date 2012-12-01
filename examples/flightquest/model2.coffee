
module.exports = (master, source, options={}) ->
        
  {alert, info, debug} = master.logger
  {repeat,wait}        = require 'ragtime'
  {C, run}             = require 'cello'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty, sha1, randInt}    = substrate.common

  # stolen from http://rosettacode.org/wiki/Averages/Root_mean_square#CoffeeScript
  RMS = (a) -> Math.sqrt (a.reduce ((s,x) -> s + x*x), 0) / a.length

  config =
    updateInterval: options.updateInterval ? 1000

  # 
  {C, run} = require 'cello'

  compile = C
    indent: "  "
    evaluate: -> [ Math.random, Math.round ]
    ignore: -> []
    debug: no

  src = compile ->
    include 'stdio.h'
    include 'string.h'

    char buffer[1024]
    int main = ->
      FILE *inputFile = fopen "test.csv", 'r'
      fgets buffer, sizeof(buffer), inputFile
      char *line = strtok buffer, ','
      0
  
  console.log src