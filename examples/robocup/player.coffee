

module.exports = (options={}) ->

  {failure, alert, success, info, debug}  = @logger
  emit = @emit
  source = @source

  SimSpark             = require 'simspark'
  {repeat,wait}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
 
  {P, copy, pretty, round2, round3, randInt}    = substrate.common

  # Errors have a cost, and impact the motivation of the player
  # a player not motivated might declare forfeit the game -> death!
  motivation = 10000
  ERR = substrate.errors (value, msg) -> motivation -= value ; msg

  #############
  # VARIABLES #
  #############
  number = options.game.number ? 0
  team   = options.game.team
  side   = 'Left'
  state = 'connecting'
  playmode = ''
  t = 0

  alert "connecting to the game server.."
  sim = new SimSpark()

  sim.on 'close', ->  
    state = 'disconnected'
  
  sim.on 'error', (er) ->
    alert "simspark error: " + pretty er
    state = 'disconnected'

  sim.on 'connect', ->
    state = 'waiting'
    alert "connected! preparing the scene.."
    sim.send [
      [ "scene", options.game.scene ]
      [ "init", [[ "unum", number ],[ "teamname", team ]]]
    ]


    # keep track of what we sent in last, to save badnwidth and calls
    alreadySet = []
    buffer = []
    
    # flush changes, by sending a batch of events to the webserver
    # this is an optimized batch, aiming at saving the number of packets, and packet size
    flush = ->
      batch = for i in [0...buffer.length]
        continue unless buffer[i]? # when writing to random array position, the first may be empty
        continue if isNaN buffer[i]
        buffer[i] = round3 buffer[i] # round the value to 2 decimals
        continue if buffer[i] is alreadySet[i]
        # if value changed, we updated SPEEDS and sned an update message
        alreadySet[i] = buffer[i]
        [ options.robot.effectors[i], buffer[i] ]
      buffer = []
      sim.send batch
      batch

    sim.on 'gs', (args) ->
      #debug 'game state'
      for nfo in args
        switch nfo[0]
          when 't'  then t = nfo[1]
          when 'pm' then playmode = nfo[1]
          else
            alert "unknow GS attribute: " + pretty nfo

    sim.on 'time', (args) ->
      # timestamp

    sim.on 'agentstate', (args) ->
      temperature = args[0][1]
      battery     = args[1][1]
      debug "temperature: #{temperature}, battery: #{battery}"


    sim.on 'frp', (args) ->
      #debug "Sensor: Force-resistance: " + pretty args

    sim.on 'gyr', (args) ->
      #debug "Sensor: Gyroscope: " + pretty args

    sim.on 'acc', (args) ->
      #debug "Sensor: Acceleration: " + pretty args
            
    sim.on 'see', (args) ->
      #debug "Sensor: Simplified vision"


    sim.on 'hj', (args) ->
      #debug "Sensor: Hinge Joint"
      # do something with the value
      # 
      # t is important, it tells the player if he should hurry or not
      # we should keep an history of effectors and sensors,
      # and game state - this is important for overall dynamic gameplay
      buffer[0]   = mutable  0.5 * Math.random() + 0.001 * t
      buffer[1]   = mutable  0.5 * Math.random() + 0.001 * t 
      buffer[2]   = mutable  0.5 * Math.random() + 0.001 * t
      buffer[3]   = mutable  0.5 * Math.random() + 0.001 * t
      buffer[4]   = mutable -0.5 * Math.random() + 0.001 * t
      buffer[5]   = mutable  0.5 * Math.random() + 0.001 * t
      buffer[6]   = mutable  0.5 * Math.random() + 0.001 * t
      buffer[7]   = mutable  0.5 * Math.random() + 0.001 * t
      buffer[8]   = mutable  0.5 * Math.random() + 0.001 * t
      buffer[9]   = mutable  0.5 * Math.random() + 0.001 * t
      buffer[10]  = mutable  0.5 * Math.random() + 0.001 * t
      buffer[11]  = mutable  0.5 * Math.random() + 0.001 * t
      buffer[12]  = mutable  0.5 * Math.random() + 0.001 * t
      buffer[13]  = mutable  0.5 * Math.random() + 0.001 * t
      buffer[14]  = mutable -0.5 * Math.random() + 0.001 * t
      buffer[15]  = mutable  0.5 * Math.random() + 0.001 * t
      buffer[16]  = mutable  0.5 * Math.random() + 0.001 * t
      buffer[17]  = mutable  0.5 * Math.random() + 0.001 * t
      buffer[18]  = mutable -0.5 * Math.random() + 0.001 * t
      buffer[19]  = mutable  0.5 * Math.random() + 0.001 * t
      buffer[20]  = mutable  0.5 * Math.random() + 0.001 * t
      buffer[21]  = mutable  0.5 * Math.random() + 0.001 * t
 
    reproduce = (onComplete) -> process.nextTick ->
      alert "reproducing"
      clone 
        src       : source
        ratio     : 0.60 # Math.min 0.60, mutable 0.40
        iterations:  2
        onComplete: (src) ->
          #debug "sending fork event: \"#{source}\""
          emit fork: src: source
          wait(1)(onComplete) if onComplete?

    exit = (code=0) -> process.nextTick ->
      alert 'exiting..'
      #simspark.close()
      emit die: code
      wait(300) -> process.exit code

    #############
    # MAIN LOOP #
    #############
    step = 0
    do looper = ->

      # http://simspark.sourceforge.net/wiki/index.php/Play_Modes
  
      switch playmode
        when 'BeforeKickOff'
          debug "Before Kick Off"
          alert "scene ready! waiting for kick off.."

        when 'KickOff_Left'
          debug "Kick Off Left"

        when 'KickOff_Right'
          debug "Kick Off Right"

        when 'PlayOn'
          debug "Play On"

        when 'KickIn_Left'
          debug "Kick In Left"

        when 'KickIn_Right'
          debug "Kick In Right"

        when 'corner_kick_left'
          debug "Corner Kick Left"

        when 'corner_kick_right'
          debug "Corner Kick Right"

        when 'goal_kick_left'
          debug "Goal Kick Left"

        when 'goal_kick_right'
          debug "Goal Kick Right"

        when 'offside_left'
          debug "Offside Left"

        when 'offside_right'
          debug "Offside Right"

        when 'GameOver'
          debug "Game Over"
          state = 'ended'

        when 'Goal_Left'
          debug "Goal Left"

        when 'Goal_Right'
          debug "Goal Right"

        when 'free_kick_left'
          debug "Free Kick Left"

        when 'free_kick_right'
          debug "Free Kick Right"

      switch state
        when 'play'
          step++
          flushed = flush()
          #if flushed.length
          #  debug "flushed: " + pretty flushed

          if step is 10
            do reproduce

          if step is 20
            state = 'ended'

        when 'connecting'
          alert "connecting to the server.."

        when 'waiting'
          debug "waiting for the scene to be installed.."
          if playmode is 'KickOff_Left' or playmode is 'PlayOn'
            debug "we can play!"
            state = 'play'

        when 'ended', 'disconnected'
          if state is 'exit'
            debug "exit in progress.."
          else
            if state is 'ended'
              debug "simulation ended"
            else
              debug "we are disconnected"
            state = 'exit'
            do exit
      
      wait(options.engine.updateInterval) looper

  {}
