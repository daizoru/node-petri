# data is too big to fit in memory so we will keep it
# in a big database, and agents will access it

fs = require 'fs'

redis = require 'redis'
csv = require 'csv'

db = redis.createClient()
# we don't need to wait for connect/ready event,
# since node-redis will buffer commands until it can
# communicate with the server. 
db.on "error", (err) ->
  console.log "Redis error: " + err

inputFilePath = __dirname + "/"
inputFilePath += "data/training/SingleTrainingDay_2012_11_20/"
inputFilePath += "metar/flightstats_metarreports_combined.csv"

quit = ->
  console.log "exiting"
  db.quit()

inputStream = fs.createReadStream inputFilePath
csv().from.stream(inputStream).on("record", (data, index) ->
  if Math.random() < 0.001
    console.log "#" + index + " " + JSON.stringify(data)
).on("end", (count) ->
  console.log "Number of lines: " + count
  quit()
).on "error", (error) ->
  console.log error.message
  quit()

# The relevant data is divided into folders by day. For these purposes, 
# a "day" includes all of the time from 1amPST/4amEST/9amUTC on that day
# until the same time on the next day. So Nov. 11, 2012 is considered to
# be from 9am UTC on Nov. 11, 2012 until 9am UTC on Nov. 12, 2012.

#loadData __dirname + "/sample.in"

#'data/training/SingleTrainingDay'