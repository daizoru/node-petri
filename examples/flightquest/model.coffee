
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

    compile = C
      indent: "  "
      evaluate: -> [ Math.random, Math.round ]
      ignore: -> []
      debug: no

    src = compile ->
      include 'stdio.h'
      include 'stdlib.h'
      include 'string.h'

      
      char buffer[1024]

      int main = (argc, argv, envp) -> 
        int argc
        char* $argv
        char* $envp

        int nbDatasetPaths = argc - 2
        printf "nb files in dataset: %i\\n", nbDatasetPaths
        # read from STDIN
        ###
        char* content = malloc  100 * sizeof char
        char c
        if content isnt NULL
          content[0] = '\0'
           while ((c = getchar()) isnt EOF)
              if strlen(content) < 100
                strcat content, c
                content[strlen(content)-1] = '\0'
        #free content
        ###


        
        # TODO read this from STDIN (\n-separated) or ARGV
        char* flight = argv[1]

        # TODO we need to find an algorithm which will read
        # the dataset "on demand" and in an efficient way
        # so we don't need to load everything in memory
        int i = 2
        while i++ < argc
          char* datasetPath = argv[2]
          printf " dataset -> %s\\n", datasetPath
          #FILE *inputFile = fopen datasetPath, 'r'
          #fgets buffer, sizeof(buffer), inputFile
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
        [flight, runway, gate] = out.replace('\n','').split ','
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






