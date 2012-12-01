
module.exports = (master, source, options={}) ->
        
  {alert, info, debug} = master.logger
  colors               = require 'colors'
  {repeat,wait}        = require 'ragtime'
  {C, run}             = require 'cello'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty, sha1, randInt}    = substrate.common

  pretty = (obj) -> "#{inspect obj, no, 20, yes}"
  # stolen from http://rosettacode.org/wiki/Averages/Root_mean_square#CoffeeScript
  RMS = (a) -> Math.sqrt (a.reduce ((s,x) -> s + x*x), 0) / a.length

  # evaluate a prediction: this should do a query to the training database
  # to check how close we are from the target arrival time
  evaluateResults = (predictedData, realData) ->
    gateDeviation   = 0
    runwayDeviation = 0

    length = 0
    for flight, real of realData
      length++
      predicted        = predictedData[flight]
      console.log "flight: #{flight}, predictedData: #{pretty predictedData}, predicted: #{predicted}"
      gate             = predicted.gate   - real.gate
      gateDeviation   += gate * gate
      runway           = predicted.runway - real.runway
      runwayDeviation += runway * runway
      console.log "  - measuring error on flight #{flight}: #{Math.round Math.abs(runway), 2} minutes"
      
    gateDeviation   /= length
    runwayDeviation /= length
    
    # compute final RMSE for the given predicted flight schedule
    (0.75 * gateDeviation) + (0.25 * runwayDeviation)


  config =
    updateInterval: options.updateInterval ? 1000

  predictFlight = (flight, onComplete=->) ->

    compile = C
      indent: "  "
      evaluate: -> [ Math.random, Math.round ]
      ignore: -> []
      debug: no

    src = compile ->
      include 'stdio.h'
      include 'string.h'

      
      char buffer[1024]
      int mode = 1 # 0 is nothing, 1 is CSV, 2 is JSON

      int main = ->

        char *flight = "DELTA-9196"
        char *datasetPath = "data/training/SingleTrainingDay_2012_11_20/"
        FILE *inputFile = fopen datasetPath, 'r'
        fclose inputFile
        #fgets buffer, sizeof(buffer), inputFile
        #char *line = strtok buffer, ','

        int runway = 0
        int gate = 0

        # CSV
        if mode is 1
          printf "%s,%i,%i\\n", flight, 0, 0

        # JSON
        if mode is 2
          printf "{\\n"
          printf "  \\\"flight\\\": \\\"%s\\\",\\n", flight
          printf "  \\\"result\\\": 0\\n"
          printf "}\\n"

        0
    
    console.log src

    # TODO pass the flight namem as argument

    run src, (err, prediction) ->
      if err
        onComplete err, {}
        return

      [flight, runway, gate] = prediction = prediction.replace('\n','').split ','
      #console.log "prediction: "+ pretty prediction
      # also a JSON mod
      #prediction = JSON.parse prediction
      #console.log pretty prediction
      onComplete undefined, {flight, runway, gate}
    

  predictFlights = (flights, onComplete=->) ->
    predictedData = {}
    for flight in flights
      do (flight) ->
        predictFlight flight, (err, predicted) ->
          if err
            console.log "#{err}".red
            predictedData[flight] = {flight: flight, gate: 0, runway: 0}
          else
            #console.log "prediction: " + pretty predicted
            predictedData[flight] = predicted
          if Object.keys(predictedData).length is flights.length
            onComplete predictedData
     
  loadVerificationData = (onComplete=->) ->
    real = {}
    for flight in flights
      real[flight] =
        flight: flight
        gate: Math.round Math.random()  * 60 * 3, 2
        runway: Math.round Math.random()  * 60 * 3, 2
    onComplete real


  ###########################
  # MAIN PROGRAM / WORKFLOW #
  ###########################
  flights = [
    'DELTA-9196'
  ]
  console.log "Step 1. Pedicting flights.."
  predictFlights flights, (predicted) ->
    console.log "Step 2. Loading verification dataset.."
    loadVerificationData (real) ->
      console.log "Step 3. Measuring deviation.."
      rmse = evaluateResults predicted, real
      console.log "finalRMSE: #{rmse}"





