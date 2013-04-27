

module.exports = (options={}) ->

  {failure, alert, success, info, debug}  = @logger
  emit = @emit
  source = @source

  SimSpark             = require 'simspark'
  {repeat,wait}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
 
  {P, copy, pretty}    = substrate.common
  
  Nao = 
    nbEffectors: 22
    effectors: [
      #      No.   Description          Hinge Joint Perceptor name  Effector name
      'he1'  # 0   Neck Yaw             [0][0]      hj1             he1
      'h2'   # 1   Neck Pitch           [0][1]      hj2             he2

      'lae1' # 2   Left Shoulder Pitch  [1][0]      laj1            lae1
      'lae2' # 3   Left Shoulder Yaw    [1][1]      laj2            lae2
      'lae3' # 4   Left Arm Roll        [1][2]      laj3            lae3
      'lae4' # 5   Left Arm Yaw         [1][3]      laj4            lae4
      'lle1' # 6   Left Hip YawPitch    [2][0]      llj1            lle1
      'lle2' # 7   Left Hip Roll        [2][1]      llj2            lle2
      'lle3' # 8   Left Hip Pitch       [2][2]      llj3            lle3
      'lle4' # 9   Left Knee Pitch      [2][3]      llj4            lle4
      'lle5' # 10  Left Foot Pitch      [2][4]      llj5            lle5
      'lle6' # 11  Left Foot Roll       [2][5]      llj6            lle6

      'rle1' # 12  Right Hip YawPitch   [3][0]      rlj1            rle1
      'rle2' # 13  Right Hip Roll       [3][1]      rlj2            rle2
      'rle3' # 14  Right Hip Pitch      [3][2]      rlj3            rle3
      'rle4' # 15  Right Knee Pitch     [3][3]      rlj4            rle4
      'rle5' # 16  Right Foot Pitch     [3][4]      rlj5            rle5
      'rle6' # 17  Right Foot Roll      [3][5]      rlj6            rle6
      'rae1' # 18  Right Shoulder Pitch [4][0]      raj1            rae1
      'rae2' # 19  Right Shoulder Yaw   [4][1]      raj2            rae2
      'rae3' # 20  Right Arm Roll       [4][2]      raj3            rae3
      'rae4' # 21  Right Arm Yaw        [4][3]      raj4            rae4
    ]

  round2 = (x) -> Math.round(x*100)/100
  round3 = (x) -> Math.round(x*1000)/1000
  randInt = (min,max) -> Math.round(min + Math.random() * (max - min))


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

  # Errors have a cost
  health = 10000
  ERR = substrate.errors (value, msg) -> health -= value ; msg


  journal = config.engine.journal
  journalize = no # disabled for now

  number = config.game.number
  team   = config.game.team
  side   = 'Left'

  state = 'connecting'
  playmode = ''

  alert "connecting to the game server.."
  simspark = new SimSpark config.server.host, config.server.port

  simspark.on 'connect', ->
    success "connected"
    state = 'waiting'

    # SEND INITIALIZATION DATA TO SIMULATION
    wait(500) ->
      alert "installing the scene and player.."
      simspark.send [
        [ "scene", config.game.scene ]
        [ "init", 
          [ 
            [ "unum",     number ]
            [ "teamname", team   ] 
          ]
        ]
      ]


      # beam effector, to position a player
      #sim.send ['beam', 10.0, -10.0, 0.0 ]


    simspark.on 'data', (events) ->

      #debug "events: " + pretty events

      for evt in events
        switch evt[0]
          when 'GS'
            for nfo in evt[1..]
              switch nfo[0]
                when 't'  then 0
                when 'pm' then playmode = nfo[1]
                else
                  alert "unknow code " + nfo[0]


      # ADD TO THE GAME EVENTS JOURNAL
      #if journalize
      #  journal.unshift events
      #  journal.pop() if journal.length > config.engine.journalSize

    simspark.on 'close', -> 
      alert "disconnected from server"
      state = 'disconnected'
  
    simspark.on 'error', (er) ->
      alert "simspark error: " + pretty er
      state = 'disconnected'

    S = for i in [0...Nao.nbEffectors]
      0.0
    sendUpdates = (U) ->
      updates = for i in [0...U.length]
        U[i] = round3 U[i] # round the value to 2 decimals
        continue if S[i] is U[i]
        # if value changed, we updated SPEEDS and sned an update message
        S[i] = U[i]
        [ Nao.effectors[i], S[i] ]
      simspark.send updates
      updates

  
    play = (t) ->
      #out.push ['lae3', 5.3]

      # hello world
      U = for i in [0...Nao.nbEffectors]
        S[i]

      if no
        U[2]  = 0.5 * (Math.random())
        U[12] = 0.5 * (Math.random())
        U[9]  = 0.5 * (Math.random())
        U[7]  = 0.5 * (Math.random())
        U[5]  = 0.5 * (Math.random())


      global_speed = 1.0

      U[2]  = global_speed * mutable(0.1 * Math.random() + 0.01 * t)
      U[12] = global_speed * mutable(0.1 * Math.random() + 0.01 * t)
      U[9]  = global_speed * mutable(0.1 * Math.random() + 0.01 * t)
      U[7]  = global_speed * mutable(0.1 * Math.random() + 0.01 * t)
      U[5]  = global_speed * mutable(0.1 * Math.random() + 0.01 * t)

      updated = sendUpdates U
      if updated.length
        debug "updates: " + pretty updated

    reproduce = (onComplete) -> process.nextTick ->
      alert "reproducing"
      clone 
        src       : source
        ratio     : Math.min 0.60, mutable 0.01
        iterations:  2
        onComplete: (src) ->
          debug "sending fork event: \"#{source}\""
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


      #######################
      # SimSpark Play Modes #
      #######################
      # http://simspark.sourceforge.net/wiki/index.php/Play_Modes
  
      switch playmode
        when 'BeforeKickOff'
          debug "Before Kick Off"
          alert "scene ready! waiting for kick off.."

          # too bad the player cannot be a machine learning monitor too
          #simspark.send [[ 'playMode', 'KickOff_Left' ]]
          #state = 'kickoff requested'

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
          play step++                 # synchronous
          do reproduce if step is 10  # asynchronous
          if step is 20 # asynchronous
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
            debug "simulation ended, or we are disconnected"
            state = 'exit'
            do exit
      
      wait(config.engine.updateInterval) looper

  {}
