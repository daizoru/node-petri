
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

  predictFlight = (flight, onComplete=->) ->
    red = (str) -> "#{str}".red
    compile = C
      indent: "  "
      evaluate: -> [ Math.random, Math.round, red ] # todo: add .red and stuff? is it even possible?
      ignore: -> []
      debug: yes

    src = compile ->
      include 'stdio.h'
      include 'stdlib.h'
      include 'string.h'

      int main = (argc, argv, envp) -> 
        # since coffeescript has no typing, we need to type the
        # parameters manually (does it looks easy enough?)
        int argc; char* $argv; char* $envp;

        int nbDataFiles = argc - 2
        printf "nb files in dataset: %i\\n", nbDataFiles

        puts red "test"

        char* flight = argv[1]
        int i = 1 # we skip the first line (0)
        while ++i < argc
          char* datasetPath = argv[2]
          printf " searching %s\\n", datasetPath
          FILE *file = fopen datasetPath, 'r'
          unless file
            puts "couldn't load file"
            continue

          ##############
          # READ LINES #
          ##############
          char line[2048]
          int r = 0
          while fgets line, sizeof(line), file
            line[strcspn line, "\\n"] = '\\0'
            continue if line[0] is '\\0'
            puts line

            break if r++ >= 10


            # fgets buffer, sizeof(buffer), inputFile
            #char *line = strtok buffer, ','
            #fclose inputFile
            #printf "--> %s\\n", line

        int runway = 0
        int gate = 0

        printf "%s,%i,%i\\n", flight, 0, 0
        0
    
    console.log src

    datasetPaths = [
       "data/training/SingleTrainingDay_2012_11_20/otherweather/flightstats_taf.csv"
       #"data/training/SingleTrainingDay_2012_11_20/otherweather/flightstats_tafforecast.csv"
       #"data/training/SingleTrainingDay_2012_11_20/otherweather/flightstats_tafsky.csv"
    ]

    args = [ flight ].concat datasetPaths
    
    ###################################
    # COMPILE AND EXECUTE THE PROGRAM #
    ###################################
    run src, args, (err, out) ->
      if err
        console.log "error: #{err}".red
        onComplete err, {}
      else
        console.log "raw output: #{out}"
        lines = out.split '\n'
        line = lines[lines.length - 2]
        console.log "line: #{line}"
        [flight, runway, gate] = line.replace('\n','').split ','
        onComplete undefined, {flight, runway, gate}
    

  ####################################
  # PREDICT A LIST OF FLIGHT (ASYNC) #
  ####################################
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
     
  #########################
  # LOAD TRAINING DATASET #
  #########################
  loadVerificationData = (onComplete=->) ->
    real = {}
    for flight in flights
      real[flight] =
        flight: flight
        gate: Math.round Math.random()  * 60 * 3, 2
        runway: Math.round Math.random()  * 60 * 3, 2
    onComplete real


  #####################################
  # RESUME AGENT'S NORMAL LIFE        #
  # (REPRODUCTION, MUTATION, DEATH..) #
  #####################################
  resumeLife = (rmse) ->
    console.log "resuming life.."
    if P mutable 0.20
      debug "reproducing"
      clone 
        src       : source
        ratio     : 0.01
        iterations:  2
        onComplete: (src) ->
          debug "sending fork event"
          master.send fork: src

  ###########################
  # MAIN PROGRAM / WORKFLOW #
  ###########################
  flights = options.flights ? []
  console.log "Step 1. Predicting flights.."
  predictFlights flights, (predicted) ->
    console.log "Step 2. Loading verification dataset.."
    loadVerificationData (real) ->
      console.log "Step 3. Measuring deviation.."
      rmse = evaluateResults predicted, real
      console.log "finalRMSE: #{rmse}"
      resumeLife rmse






