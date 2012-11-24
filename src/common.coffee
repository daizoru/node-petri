crypto = require 'crypto'
deck = require 'deck'
os = require 'os'


# make a random, mostly unique id
makeId = exports.makeId = -> (Number) ("#{new Date().valueOf()}#{Math.round(Math.random() * 10000)}")

sha1 = exports.sha1 = (src) ->
  shasum = crypto.createHash 'sha1'
  shasum.update src
  shasum.digest 'hex'

copy =  exports.copy = (a) -> JSON.parse(JSON.stringify(a))

P           = exports.P = (p=0.5) -> + (Math.random() < p)
isFunction  = exports.isFunction = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)
isUndefined = exports.isUndefined = (obj) -> typeof obj is 'undefined'
isArray     = exports.isArray = (obj) -> Array.isArray obj
isString    = exports.isString = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))
isNumber    = exports.isNumber = (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
isBoolean   = exports.isBoolean = (obj) -> obj is true or obj is false
isString    = exports.isString = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))

toStr = exports.toStr = (func) -> func.toString()

# return nb cores - 2, to save OS cpu
NB_CORES = exports.NB_CORES = do ->
  cpus = Math.round(os.cpus().length)
  if (cpus < 3) then 1 else (cpus - 2)


# we just hide the underlying implementation
pick = exports.pick = deck.pick
shuffle = exports.shuffle = deck.shuffle

