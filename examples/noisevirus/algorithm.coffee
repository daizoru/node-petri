
module.exports = (master, source, options={}) ->

  baudio               = require 'baudio'
  colors               = require 'colors'
  pcm                  = require 'pcm'
  {wait,repeat}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty, round}    = substrate.common
  {failure, alert, success, info, debug} = master.logger

  n = 0; m = 0; z = 0; q = 1; t = 0
  wave = for i in [0..options.dataset.length]
    t = mutable t + 0.00001 + 0.00002 + 0.00002
    x = mutable Math.sin t * ( 26 * 100.0) + Math.sin(n) +  Math.sin(2 * t)   * (q -=  0.01)
    n = mutable n + Math.sin(t * 3 * Math.random() * 0.01 * Math.PI) + 0.002 
    
    # death geiger filter
    n = mutable if n > 20 then 5 * Math.random() else n

    # reset / loop q
    #q = mutable if q < 0.01 then 1 * Math.random() else q

    m = mutable m + Math.sin(2 * t)

    # LIMITER
    x = -1.0 if x < -1.0
    x = +1.0 if x > 1.0

    # CORRUPTED SIGNAL PROTECTION
    process.exit 2 unless -1.0 < x < 1.0

    x
  #console.log "waveform: #{wave}"

  sumOfDeltas = 0
  length = 0
  onData = (sample, channel) ->
    if channel is options.dataset.channel
      sumOfDeltas += Math.abs wave[length++] - sample

  onEnd = (err, output) ->
    if err
      failure "error: #{err}"
      process.exit 1
    #debug "sample loaded (length: #{length})"

    errorDelta = sumOfDeltas / length # errorDelta will be [0.0, 1.0]
    process.exit 3 unless 0.0 < errorDelta < 0.99

    #alert "mutating.."
    clone 
      src       : source
      ratio     : mutable 0.90
      iterations:  3
      onComplete: (src) ->
        #success "mutated!"
        #debug "#{round errorDelta, 4}"
        child = 
          src: src
          errorDelta: errorDelta

        # should we send a waveform?
        if options.playback
          child.wave = wave

        master.send fork: child
        process.exit 0
  
  #debug "loading sample.."
  conf = stereo: options.dataset.stereo, sampleRate: options.dataset.sampleRate
  pcm.getPcmData options.dataset.file, conf, onData, onEnd

  {}
