# a strain which try to copy another sample
# todo: we need to compare the performance of one individual compared to all others
# so that particularly good performing ones have much more chance to reproduce
# than average (this should give results similar to "tournaments" of others GAs)
module.exports = (master, source, options={}) ->

  #redis = require 'redis'
  #client = redis.createClient()


  baudio               = require 'baudio'
  colors               = require 'colors'
  pcm                  = require 'pcm'
  {wait,repeat}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty}    = substrate.common
  {failure, alert, success, info, debug} = master.logger

  pretty = (obj) -> "#{inspect obj, no, 20, yes}"

  global = options.global
  dataset = options.dataset
  shared = options.shared

  console.log "dataset: " + pretty dataset
  console.log "shared: " + pretty shared

  n = 0
  m = 0
  z = 0
  q = 1
  t = 0
  wave = for i in [0..dataset.length]
    t = mutable t + 0.00001 + 0.00002 + 0.00002
    x = mutable Math.sin t * ( 26 * 100.0) + Math.sin(n) +  Math.sin(2 * t)   * (q -=  0.01)
    n = mutable n + Math.sin(t * 3 * Math.random() * 0.01 * Math.PI) + 0.002 
    
    # death geiger filter
    n = mutable if n > 20 then 5 * Math.random() else n

    # reset / loop q
    #q = mutable if q < 0.01 then 1 * Math.random() else q

    m = mutable m + Math.sin(2 * t)
    x
  #console.log "waveform: #{wave}"


  deltas = 0
  length = 0
  pcmConfig = 
    stereo: no
    sampleRate: dataset.sampleRate
  referenceFile = dataset.file
  onData = (sample, channel) ->
    return unless channel is dataset.channel
    # Sample is from [-1.0...1.0], channel is 0 for left and 1 for right
    #min = Math.min min, sample
    #max = Math.max max, sample

    # TODO compare how far we are from reference model
    # more distance == more penalty == less reproduction probability
    generated = wave[length++]
    delta = Math.abs generated - sample
    #console.log "chan: #{channel}, sample: #{sample}, generated: #{generated}, delta: #{delta}"
    deltas += delta
    #length++

  onError = (err, output) ->
    if err
      failure "error: #{err}"
      throw new Error err
    debug "sample loaded (length: #{length})"

    # between 0 and about 1
    e = deltas / length
    if !isFinite(e)
      failure "failure, bad function"
      process.exit 3

    min = Math.min shared.errorRate.min, e
    max = Math.max shared.errorRate.max, e

    adjusted = min + (e / (max - min))

    debug "#{adjusted} = #{min} + (#{e} / (#{max} - #{min}))"

    if P adjusted * 0.1
      failure "bad score and bad luck (error: #{adjusted})"
      process.exit 2
    else
      success "lucky enough to reproduce (error: #{adjusted})"

    # output the music, not for debug but for fun
   
    b = baudio()
    i = 0
    b.push (t) ->
      x = wave[i++]
      out = x * global.gain
      if i >= wave.length
        alert "mutating.."
        clone 
          src       : source
          ratio     : mutable 0.80
          iterations:  3
          onComplete: (src) ->
            success "mutated"
            master.send data: errorRate: adjusted
            master.send fork: src
            process.exit 0

      else
        # KILL INDIVIDUALS, NOT EARS
        if !isFinite(out) or Math.abs out > 0.1
          failure "failure, bad playback"
          process.exit 1
      out
    b.play()
  
  debug "loading sample.."
  pcm.getPcmData referenceFile, pcmConfig, onData, onError

  {}
