crypto    = require "crypto"

isFunction  = exports.isFunction = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)

# make a random, mostly unique id
makeId = exports.makeId = -> (Number) ("#{new Date().valueOf()}#{Math.round(Math.random() * 10000)}")

sha1 = exports.sha1 = (src) ->
  shasum = crypto.createHash 'sha1'
  shasum.update src
  shasum.digest 'hex'

P = exports.P = (p=0.5) -> +(Math.random() < p)

# return nb cores - 2, to save OS cpu
nbcores = exports.nbcores = ->
  cpus = Math.round(os.cpus().length)
  if (cpus < 3) then 1 else (cpus - 2)