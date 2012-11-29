
module.exports = (master, source, options={}) ->
        
  {alert, info, debug} = master.logger
  {repeat,wait}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty, sha1, randInt}    = substrate.common

  config =
    data:
      training: options.data?.training ? ""
    updateInterval: options.updateInterval ? 1000
  
  throw new Error "Not Implemented"

  # The information will include: flight number, origin, destination, 
  # take-off time, arrival time, latitude and longitude at frequent 
  # interim waypoints along the journey, and weather and wind data.
  # Based on this information, entrants are challenged to design an 
  # algorithm for a flight management system that increases predictive
  # efficiency.

  # "You will be provided with relevant data for each day that would
  # be available at the chosen cutoff time. Predictions for each flight
  # on a given day can not reference any data related to future dates
  # in the evaluation data set."


  days = []


  # To compute:
  # gate arrival times
  # runway arrival times

  # details on: https://www.gequest.com/wiki/FlightQuest.Data