#!/usr/bin/env coffee

#########################
# STANDARD NODE LIBRARY #
#########################
fs        = require 'fs'
{inspect} = require 'util'

#################
# THIRD-PARTIES #
#################
redis     = require 'redis'
csv       = require 'csv'

##############################
# ESTABLISH CONNECTION TO DB #
##############################
db = redis.createClient() # will buffer commands until connection
db.on "error", (err) ->
  console.log "Redis error: " + err

############################
# SIMPLE UTILITY FUNCTIONS #
############################
pretty = (obj) -> "#{inspect obj, no, 20, yes}"
Array::sample = (size=30) -> 
  if @length then (@[i] for i in [0...@length] by Math.round @length / size) else @

quit = (code=0) ->
  console.log "exiting"
  db?.quit?()
  process.exit code

##################################
# GENERIC CSV-TO-OBJECT IMPORTER #
##################################
importCSV = (inputFilePath, onComplete=->) ->

  console.log inputFilePath

  inputStream = fs.createReadStream inputFilePath
  columns     = []
  store       = []

  csv().from.stream(inputStream).on("record", (data, index) ->
    if index is 0
      columns = data
      return
    obj = {}
    for i in [0...columns.length]
      obj[columns[i]] = data[i]
    store.push obj

    # random logging
    #return if Math.random() > 0.001
    #console.log "#" + index + " " + JSON.stringify(data)

  ).on("end", (count) ->
    console.log "Number of lines: " + count
    console.log "columns: " + columns
    onComplete store

  ).on "error", (error) ->
    console.log "error: " + error.message
    
#######################
# IN-MEMORY DATASTORE #
#######################
database = {}

################
# DATASET PATH #
################
trainingDataset = "SingleTrainingDay_2012_11_20"
trainingDatapath = "#{__dirname}/data/training/#{trainingDataset}/"

##########################
# SPECIFIC CSV FILE PATH #
##########################

#inputFilePath += "metar/flightstats_metarreports_combined.csv"
filePath = "#{trainingDatapath}/otherweather/flightstats_taf.csv"
importCSV filePath, (data) ->
  console.log "data import terminated"
  database.weather = data
  console.log "database: " + pretty database.weather.sample(10)
  quit()

# wind reports have to be associated


# The relevant data is divided into folders by day. For these purposes, 
# a "day" includes all of the time from 1amPST/4amEST/9amUTC on that day
# until the same time on the next day. So Nov. 11, 2012 is considered to
# be from 9am UTC on Nov. 11, 2012 until 9am UTC on Nov. 12, 2012.

#loadData __dirname + "/sample.in"

#'data/training/SingleTrainingDay'