{inspect} = require 'util'
crypto    = require 'crypto'
os        = require 'os'

deck      = require 'deck'

# make a random, mostly unique id
makeId = exports.makeId = -> (Number) ("#{new Date().valueOf()}#{Math.round(Math.random() * 10000)}")

copy        = exports.copy        = (a) -> JSON.parse(JSON.stringify(a))
P           = exports.P           = (p=0.5) -> + (Math.random() < p)
isFunction  = exports.isFunction  = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)
isUndefined = exports.isUndefined = (obj) -> typeof obj is 'undefined'
isArray     = exports.isArray     = (obj) -> Array.isArray obj
isString    = exports.isString    = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))
isNumber    = exports.isNumber    = (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
isBoolean   = exports.isBoolean   = (obj) -> obj is true or obj is false
isString    = exports.isString    = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))
toStr       = exports.toStr       = (func) -> func.toString()

round = exports.round = (value, d = 4) ->
  x = Math.pow 10, d
  Math.round(value * x) / x
  
randInt = exports.randInt = (min, max) -> 
  if isUndefined max
    Math.round Math.random() * min
  else
    Math.round(min + (Math.random() * (max - min)))

sha1   = exports.sha1   = (src) ->
  console.log "sha1fying \"#{src}\""
  shasum = crypto.createHash 'sha1'
  shasum.update new Buffer "#{src}"
  shasum.digest 'hex'


# return nb cores - 2, to save OS cpu
NB_CORES = exports.NB_CORES = do ->
  cpus = Math.round(os.cpus().length)
  if (cpus < 3) then 1 else (cpus - 2)


# we just hide the underlying implementation
pick    = exports.pick    = deck.pick
shuffle = exports.shuffle = deck.shuffle

pretty = exports.pretty   = (obj) -> "#{inspect obj, no, 20, yes}"
  

readFile = exports.readFile = (f) -> fs.readFileSync input, "utf8"
