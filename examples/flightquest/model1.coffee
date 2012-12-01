
module.exports = (master, source, options={}) ->
        
  {alert, info, debug} = master.logger
  {repeat,wait}        = require 'ragtime'
  {C, run}             = require 'cello'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty, sha1, randInt}    = substrate.common

  # stolen from http://rosettacode.org/wiki/Averages/Root_mean_square#CoffeeScript
  RMS = (a) -> Math.sqrt (a.reduce ((s,x) -> s + x*x), 0) / a.length

  config =
    updateInterval: options.updateInterval ? 1000

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

  fakeDatabase =
    "": ""


  # evaluate a prediction: this should do a query to the training database
  # to check how close we are from the target arrival time
  evaluateData = (prediction, verification) ->
    gateDeviation   = 0
    runwayDeviation = 0
    for i in [0...prediction.length]
      gate             = prediction[i].gate   - verification[i].gate
      gateDeviation   += gate * gate
      runway           = prediction[i].runway - verification[i].runway
      runwayDeviation += runway * runway
      console.log "  - measuring error on flight #{prediction[i].flight}: #{Math.round Math.abs(runway), 2} minutes"
    gateDeviation   /= prediction.length
    runwayDeviation /= prediction.length
    
    # compute final RMSE for the given predicted flight schedule
    finalRMSE = (0.75 * gateDeviation) + (0.25 * runwayDeviation)
    finalRMSE

  ##############################
  # RUN AND EVALUATE THE AGENT #
  ##############################
  # Each agents starts with the maximum points, then it can lost points
  # for each error. losing a lot of points increase the probability of death

  # FAKE DATA
  flights = [
    'AA-599'
  ]

  predictedData = for flight in flights
    console.log "predicting data for flight #{flight}.."
    
    # at this level, we are only authorized to use data/events that
    # happenned prior to the current timestamp

    # the current problem with the dataset is that some datasets
    # don't have timestamps, but another id (eg. weather forecast id)
    # so the importer should do the matching

    # so we need to have a function to get all data matching a specific
    # timeframe

    # predicted_runway_arrival_time: This is your predicted runway arrival 
    # time in minutes since midnight (time zone TBD). For example, 
    # 514.5 would correspond to 08:34:30AM
    runway = 0

    # predicted_gate_arrival_time = This is the predicted gate arrival time 
    # for the flight, in minutes since midnight (time zone TBD). For example, 
    # 514.5 would correspond to 08:34:30AM 
    gate = 0 

    # put the prediction algorithm here
    # ideally, this should be a mixture of code (algorithm) and data (database)

    
    {flight, runway, gate}

  # TODO download this fom the training set database
  console.log "fetching real data to verify prediction.."
  realData = for flight in flights
    # for now it is fake
    flight: flight
    gate: Math.round Math.random()  * 60 * 3, 2
    runway: Math.round Math.random()  * 60 * 3, 2

  console.log "Evaluating predictions.."
  rmse = evaluateData predictedData, realData
  console.log "RMSE: #{rmse} minutes"

  
