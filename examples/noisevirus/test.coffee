baudio = require('baudio')

n = 0
b = baudio -> (t) ->
  x = Math.sin(t * 262 + Math.sin(n))
  n += Math.sin(t)
  x

b.play()
