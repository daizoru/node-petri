exports.randomPlayers = randomPlayers = (max=1) ->
  dummy = (name) ->
    name: name
    play: (game) ->
      console.log "DUMMY PLAY"
      return if game.state isnt "complete"
      game.betting[if Math.random() < 0.5 then 'raise' else 'call']
  for i in [0...max]
    dummy "dummy #{i}"
