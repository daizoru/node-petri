
module.exports = (master, source, options={}) ->

  baudio               = require 'baudio'
  colors               = require 'colors'
  {wait,repeat}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty}    = substrate.common
  {failure, alert, success, info, debug} = master.logger

  pretty = (obj) -> "#{inspect obj, no, 20, yes}"

  cycles = 0
  do lifecycle = ->
    if cycles++ >= 12
      debug "reproducing"
      clone 
        src       : source
        ratio     : 0.60
        iterations:  2
        onComplete: (src) ->
          debug "forking musician"
          master.send fork: src
          process.exit 3
    wait(50.ms) lifecycle

  volume = 0.05
  n = 0
  m = 0
  z = 0
  q = 1
  b = baudio()
  b.push (t) ->
    x = mutable Math.sin t * ( 26 * 100.0) + Math.sin(n) +  Math.sin(2 * t)   * (q -=  0.01)
    n = mutable n + Math.sin(t * 3 * Math.random() * 0.01 * Math.PI) + 0.002 
    
    # death geiger filter
    n = mutable if n > 20 then 5 * Math.random() else n

    # reset / loop q
    #q = mutable if q < 0.01 then 1 * Math.random() else q

    m = mutable m + Math.sin(2 * t)
    #console.log "#{x * volume}"

    out = x * volume

    # KILL INDIVIDUALS, NOT EARS
    if !isFinite(out) or Math.abs out > 0.1
      process.exit 1
    out
  b.play()
  {}
