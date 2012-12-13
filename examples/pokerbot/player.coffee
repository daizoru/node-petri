
module.exports = (master, source, options={}) ->
        
  {alert, success, failure, info, debug} = master.logger
  {repeat,wait}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty, sha1, randInt}    = substrate.common


  #####################################################
  # TODO PUT THIS IN A SEPARATE "POKER SCHOOL" MODULE #
  #####################################################
  getTournament = (config) ->
    MachinePoker  = require 'machine-poker'

    randomPlayers = (max=1) ->
      dummy = (name) ->
        name: name
        play: (game) ->
          alert "DUMMY PLAY"
          return 0 if game.state isnt "complete"
          game.betting[if Math.random() < 0.5 then 'raise' else 'call']
      for i in [0...max]
        dummy "dummy #{i}"

    table = MachinePoker.create
      maxRounds: config.table.maxRounds
      chips:     config.table.chips
      betting:   MachinePoker.betting.noLimit config.table.blind, config.table.raise

    participate: (player) ->
      table.addPlayer player

    start: (onComplete=->) ->

      for p in randomPlayers randInt 10
        table.addPlayer p

      table.addObserver MachinePoker.observers.narrator
      table.addObserver MachinePoker.observers.fileLogger "./test.json"

      table.on 'ready', ->
        success 'ready'
        table.start()

      table.on 'complete', (game) ->
        onComplete game


  ##############################################



  config =
    table:
      maxRounds : options.table?.maxRounds ? 10
      chips     : options.table?.chips     ? 1000
      blind     : options.table?.blind     ? 10
      raise     : options.table?.raise     ? 20
    updateInterval: options.updateInterval ? 1000

  tournament = getTournament config

  # participate to the challenge
  tournament.participate
    name: "baskerville"
    play: (game) ->
      mutable = (x) -> x
      res = 0
      alert "BASKERVILLE PLAY"
      debug game.self
      ourcards = game.self.cards
      info "cards: #{ourcards}"
      debug "brain: #{game.self.brain}"
      # Only play the good hands
      if game.state isnt 'complete'
        if game.state is 'pre-flop'
          # Paired
          if ourcards[0][0] is ourcards[1][0]
            if ['A','K','Q','J'].indexOf(ourcards[0][0]) >= 0
              res = Math.round mutable game.betting.raise * Math.random() * 20
            else
              res = game.betting.call
          else if ['A','K'].indexOf(ourcards[0][0]) >= 0
            res = game.betting.call
          else
            res = 0
        else
          res = game.betting.call
      res
  
  tournament.start (game) ->
    failure "game terminated! checking agent's score.."
    process.exit 5


