

module.exports = (options={}) ->

  {failure, alert, success, info, debug}  = @logger
  SimSpark             = require 'simspark'
  {repeat,wait}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty}    = substrate.common
 
  round2 = (x) -> Math.round(x*100)/100

  EFFECTORS = [
    #      No.   Description          Hinge Joint Perceptor name  Effector name
    'he1'  # 1   Neck Yaw             [0][0]      hj1             he1
    'h2'   # 2   Neck Pitch           [0][1]      hj2             he2
    'lae1' # 3   Left Shoulder Pitch  [1][0]      laj1            lae1
    'lae2' # 4   Left Shoulder Yaw    [1][1]      laj2            lae2
    'lae3' # 5   Left Arm Roll        [1][2]      laj3            lae3
    'lae4' # 6   Left Arm Yaw         [1][3]      laj4            lae4
    'lle1' # 7   Left Hip YawPitch    [2][0]      llj1            lle1
    'lle2' # 8   Left Hip Roll        [2][1]      llj2            lle2
    'lle3' # 9   Left Hip Pitch       [2][2]      llj3            lle3
    'lle4' # 10  Left Knee Pitch      [2][3]      llj4            lle4
    'lle5' # 11  Left Foot Pitch      [2][4]      llj5            lle5
    'lle6' # 12  Left Foot Roll       [2][5]      llj6            lle6
    'rle1' # 13  Right Hip YawPitch   [3][0]      rlj1            rle1
    'rle2' # 14  Right Hip Roll       [3][1]      rlj2            rle2
    'rle3' # 15  Right Hip Pitch      [3][2]      rlj3            rle3
    'rle4' # 16  Right Knee Pitch     [3][3]      rlj4            rle4
    'rle5' # 17  Right Foot Pitch     [3][4]      rlj5            rle5
    'rle6' # 18  Right Foot Roll      [3][5]      rlj6            rle6
    'rae1' # 19  Right Shoulder Pitch [4][0]      raj1            rae1
    'rae2' # 20  Right Shoulder Yaw   [4][1]      raj2            rae2
    'rae3' # 21  Right Arm Roll       [4][2]      raj3            rae3
    'rae4' # 22  Right Arm Yaw        [4][3]      raj4            rae4
  ]


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


  state = 'connecting'

  alert "connecting to the game server.."
  simspark = new SimSpark config.server.host, config.server.port

  simspark.on 'connect', =>
    success "connected"
    state = 'waiting'

    # SEND INITIALIZATION DATA TO SIMULATION
    wait(2000) =>
      alert "installing the scene and player.."
      simspark.send [
        [ "scene", config.game.scene ]
        [ "init", 
          [ 
            [ "unum",     config.game.number ]
            [ "teamname", config.game.team   ] 
          ]
        ]
      ]



      # beam effector, to position a player
      #sim.send ['beam', 10.0, -10.0, 0.0 ]


    simspark.on 'data', (events) =>

      #debug "events: " + pretty events

      for evt in events
        switch evt[0]
          when 'GS'
            for nfo in evt[1..]
              switch nfo[0]
                when 't'  then 0
                when 'pm' then state = nfo[1]
                else
                  alert "unknow code " + nfo[0]


      # ADD TO THE GAME EVENTS JOURNAL
      #if journalize
      #  journal.unshift events
      #  journal.pop() if journal.length > config.engine.journalSize

    simspark.on 'close', => 
      alert "disconnected from server"
      state = 'disconnected'
  
    simspark.on 'error', (er) =>
      alert "simspark error: " + pretty er
      state = 'disconnected'

    S = for i in [0...EFFECTORS.length]
      0.0

    do main = =>
    
      # check the current state
      # http://simspark.sourceforge.net/wiki/index.php/Play_Modes
      switch state
        when 'BeforeKickOff'
          debug "Before Kick Off"
          alert "scene ready! waiting for kick off.."

          #@@@@@@@ too bad the player cannot be a machine learning monitor too
          #simspark.send [[ 'playMode', 'KickOff_Left' ]]
          #state = 'kickoff requested'


        when 'KickOff_Left'
          debug "Kick Off Left"

        when 'KickOff_Right'
          debug "Kick Off Right"

        when 'PlayOn'
          debug "Play On"

          #out.push ['lae3', 5.3]

          # hello world
          U = for i in [0...EFFECTORS.length]
            S[i]

          #U[4] += Math.random() * 2 - 1

          U[1] = 0.1 * Math.random() * 2 - 1

          #U[10] += Math.random() * 2 - 1


          # check if some effectors changed, only send changes over the network
          updates = for i in [0...U.length]
            U[i] = round2 U[i] # round the value to 2 decimals
            continue if S[i] is U[i]
            # if value changed, we updated SPEEDS and sned an update message
            S[i] = U[i]
            [ EFFECTORS[i], S[i] ]

          debug "updates: " + pretty updates
          simspark.send updates



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
          if P Math.min 1.0, mutable 1.0
            alert "reproducing"
            clone 
              src       : @source
              ratio     : Math.min 0.60, mutable 0.01
              iterations:  2
              onComplete: (src) =>
                debug "sending fork event"
                @send fork: src

        when 'Goal_Left'
          debug "Goal Left"

        when 'Goal_Right'
          debug "Goal Right"

        when 'free_kick_left'
          debug "Free Kick Left"

        when 'free_kick_right'
          debug "Free Kick Right"

        when 'connecting'
          alert "connecting to the server.."

        when 'waiting'
          debug "waiting for the scene to be installed.."

        when 'disconnected'
          state = 'exiting'
          alert "if we are disconnected, we need to exit"
          simspark.close()
          # TODO: send message to host?


        when 'exiting'
          alert 'exiting..'
          state = 'void'
          @send die: 0
          wait(600) -> process.exit 0
        when 'void'
          debug "..."
        else
          debug "Unknow state: " + state
      wait(config.engine.updateInterval) main

  {}
