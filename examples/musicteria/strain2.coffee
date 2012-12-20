
module.exports = (master, source, options={}) ->

  baudio               = require 'baudio'
  tune                 = require 'tune'
  colors               = require 'colors'
  {wait,repeat}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty}    = substrate.common
  {failure, alert, success, info, debug} = master.logger

  pretty = (obj) -> "#{inspect obj, no, 20, yes}"



  if P mutable 0.00
    debug "reproducing"
    clone 
      src       : source
      ratio     : 0.01
      iterations:  2
      onComplete: (src) ->
        debug "sending fork event"
        master.send fork: src

  b = baudio()
  ff = []
  [
    "C D E G"
    "A B C E"
    "C D E G"
    "A B C E"
    "A C F G"
    "A B D G"
    "Ab C Eb G"
    "A Bb D F"
  ].forEach (chord) ->
    chord = chord.split(" ")
    oct = 3
    arp = []
    i = 0

    while i < (chord.length - 1) * 4
      oct++  if i % 4 is 0
      arp.push chord[i % 4] + oct
      i++
    ff = ff.concat(arp.concat(arp.slice(0, -1).reverse()))

  ff = tune(ff)
  b.push (t) ->
    ff t

  b.play()

  {}
