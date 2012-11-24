
class module.exports
  constructor: (src, on, emit, options={}) ->

    # since a player is serialized, we need to 
    # put the imports inside the object
    SimSpark = require 'simspark'
    {repeat} = require 'ragtime'
    substrate = require 'substrate'

    {trivial, minor, major} = substrate.errors # - ERROR TOOLS
    {mutate,mutable}        = substrate.evolve # - EVOLUTIONARY TOOLS
    {P, copy}               = substrate.common # - MISC UTILS

    alert  = (msg) -> emit log: level: 0, msg: "ALERT #{msg}"
    info   = (msg) -> emit log: level: 1, msg: "INFO #{msg}"
    debug  = (msg) -> emit log: level: 2, msg: "DEBUG #{msg}"
    pretty = (obj) -> "#{inspect obj, no, 20, yes}"
    
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
        journalSize:  options.engine?.journalSize ? 50
        journal: options.engine?.journal ? []

    journal = config.engine.journal

    simspark = new SimSpark config.server.host, config.server.port

    client.on 'connect', ->
      debug "connected! sending messages.."

      # SEND INITIALIZATION DATA TO SIMULATION
      simspark.send [
        [ "scene", config.game.scene ]
        [ "init", [ "unum", config.game.number ], [ "teamname", config.game.team ] ]
      ]

      # beam effector, to position a player
      #sim.send ['beam', 10.0, -10.0, 0.0 ]

    simspark.on 'data', (events) ->
      debug "received new events.."
      # we intercept special/important events, to know when to stop
      #for p in events
      #  if p[0] in ['GS','AgentState']
      #    for kv in p[1..]
      #      state[kv[0]] = kv[1]

      # ADD TO THE GAME EVENTS JOURNAL
      journal.unshift events
      journal.pop() if journal.length > config.engine.journalSize

    simspark.on 'end', -> 
      emit 'log': "disconnected from server"
      run = no

    do main = ->

      ##############
      # CLEAN EXIT #
      ##############
      unless run
        emit 'log': "exiting properly"
        simspark.destroy()
        journal = []
        # TODO: send message to host?
        emit 'die': 0
        wait(500) -> process.exit 0
        return

      #############
      # MAIN CODE #
      #############

      if Maths.random() < 0.50
        emit 'fork': src

      messages = []

      #out.push ['lae3', 5.3]

      # hello world
      messages.push ['say', "hello world"]

      messages.push ['syn'] # sync agent mode - ignored if server is in RT mode

      simspark.send messages

      wait(config.engine.updateInterval) main
