
module.exports = (master, source, options={}) ->

  baudio               = require 'baudio'
  tune                 = require 'tune'
  deck                 = require 'deck'
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

  # it's a jazzy strain so it is random - or is it?
  keys =  
    '.':   mutable 70
    'A#5': mutable 40
    'Bb5': mutable 50
    'C5':  mutable 25
    'D5':  mutable 30
    'F5':  mutable 50
    'D4':  mutable 50
    'F4':  mutable 50

  notes = for i in [0..50]
    # update deck's probabilities dependending on what has been played before?

    # read nodes
    # adjust key's probabilities
    # this can be a lot of rules!
    deck.pick keys

  track = tune notes,
    tempo: 10
    volume: 1.0

  b = baudio()
  b.push (t) -> track t
  b.play()

  {}
