{inspect} = require 'util'
crypto    = require 'crypto'
os        = require 'os'
fs        = require 'fs'

deck      = require 'deck'
natural   = require 'natural'
clone     = require('node-v8-clone').clone

log = exports.log = console.log 

normalize = exports.normalize = deck.normalize

distance = exports.distance = (a, b) ->
  if isString(a) and isString(b)
    1.0 - natural.JaroWinklerDistance a, b
  else
    console.log "dist(#{a},#{b})"
    a = (Number) a
    b = (Number) b
    Math.abs Math.log(b) - Math.log(a)

every = exports.every = (ft) -> setInterval ft...
after = exports.after = (ft) -> setTimeout  ft...

# Magic Number
Number::ms      = (f) -> [f, 1 * @]
Number::second  = (f) -> [f, 1000 * @]
Number::seconds = (f) -> [f, 1000 * @]
Number::sec     = (f) -> [f, 1000 * @]
Number::minute  = (f) -> [f, 60000 * @]
Number::minutes = (f) -> [f, 60000 * @]
Number::min     = (f) -> [f, 60000 * @]
Number::hour    = (f) -> [f, 86400000 * @]
Number::hours   = (f) -> [f, 86400000 * @]
Number::day     = (f) -> [f, 86400000 * @]
Number::days    = (f) -> [f, 86400000 * @]

# make a random, mostly unique id
makeId = exports.makeId = -> (Number) ("#{new Date().valueOf()}#{Math.round(Math.random() * 10000)}")

copy        = exports.copy        = (a) -> clone a, yes

P           = exports.P           = (p=0.5) -> + (Math.random() < p)
isFunction  = exports.isFunction  = (obj) -> !!(obj and obj.constructor and obj.call and obj.apply)
isUndefined = exports.isUndefined = (obj) -> typeof obj is 'undefined'
isArray     = exports.isArray     = (obj) -> Array.isArray obj
isString    = exports.isString    = (obj) -> !!(obj is '' or (obj and obj.charCodeAt and obj.substr))
isNumber    = exports.isNumber    = (obj) -> (obj is +obj) or toString.call(obj) is '[object Number]'
isBoolean   = exports.isBoolean   = (obj) -> obj is true or obj is false
toStr       = exports.toStr       = (func) -> func.toString()

round = exports.round = (value, d = 4) ->
  x = Math.pow 10, d
  Math.round(value * x) / x
  
randInt = exports.randInt = (min, max) -> 
  if isUndefined max
    Math.round Math.random() * min
  else
    Math.round(min + (Math.random() * (max - min)))

  
round2 = exports.round2 = (x) -> Math.round(x*100)/100
round3 = exports.round3 = (x) -> Math.round(x*1000)/1000

sha1   = exports.sha1   = (src) ->
  #console.log "sha1fying \"#{src}\""
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
  
prettyCode = exports.prettyCode = (code) ->
  lines = for line in code[0].toString().split '\n'
    line.trim()

  str = lines[1...lines.length - 1].join ''
  if str is ''
    str = '[native code]'
  pretty [str].concat code[1...]

readFile = exports.readFile = (input) -> fs.readFileSync input, "utf8"

isValidNumber = exports.isValidNumber = (value) ->
  value? and !isNaN(value) and isFinite(value)
