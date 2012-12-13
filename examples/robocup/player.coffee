
module.exports = (master, source, options={}) ->

  {failure, alert, success, info, debug}  = master.logger
  SimSpark             = require 'simspark'
  {repeat,wait}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty}    = substrate.common
 
  config =
    server:
      host  : options.server?.host ? "localhost"
      port  : options.port?.port   ? 3100
    game:
      scene : options.game.scene
      team  : options.game?.team   ? "DEFAULT"
      number: options.game?.number ? 0
    engine:
      updateInterval: options.engine?.updateInterval ? 1000
      journalSize   : options.engine?.journalSize    ? 50
      journal       : options.engine?.journal        ? []

  health = 10000
  ERR = substrate.errors (value, msg) -> health -= value ; msg

  journal = config.engine.journal

  simspark = new SimSpark config.server.host, config.server.port

  simspark.on 'connect', ->
    success "connected! sending messages.."

    # SEND INITIALIZATION DATA TO SIMULATION
    simspark.send [
      [ "scene", config.game.scene ]
      [ "init", [ "unum", config.game.number ], [ "teamname", config.game.team ] ]
    ]

    # beam effector, to position a player
    #sim.send ['beam', 10.0, -10.0, 0.0 ]

  simspark.on 'data', (events) ->
    debug "received new events.." if P 0.10
    # we intercept special/important events, to know when to stop
    #for p in events
    #  if p[0] in ['GS','AgentState']
    #    for kv in p[1..]
    #      state[kv[0]] = kv[1]

    # ADD TO THE GAME EVENTS JOURNAL
    journal.unshift events
    journal.pop() if journal.length > config.engine.journalSize

  run = yes
  simspark.on 'end', -> 
    alert "disconnected from server"
    run = no

  do main = ->

    ##############
    # CLEAN EXIT #
    ##############
    unless run
      alert "exiting"
      simspark.destroy()
      journal = []
      # TODO: send message to host?
      master.send die: 0
      wait(500) -> process.exit 0
      return

    #############
    # MAIN CODE #
    #############

    if P mutable 0.20
      alert "reproducing"
      clone 
        src       : source
        ratio     : 0.01
        iterations:  2
        onComplete: (src) ->
          debug "sending fork event"
          master.send fork: src

    messages = []

    #out.push ['lae3', 5.3]

    # hello world
    messages.push ['say', "hello world"]

    messages.push ['syn'] # sync agent mode - ignored if server is in RT mode

    simspark.send messages

    wait(config.engine.updateInterval) main

  {}
