
cluster          = require 'cluster'
{inspect}        = require 'util'
deck             = require 'deck'
{map,wait}       = require 'ragtime'
{mutable,mutate} = require 'evolve'
timmy            = require 'timmy'

#Memory           = require './memory'
{P, makeId, sha1, pick} = require '../common'

module.exports = (options={}) ->
  console.log "WORKER STARTED"
  # worker-specific functions
  outputs = (msg) -> process.send JSON.stringify msg
  inputs  = (cb) -> 
    process.on 'message', (msg) -> 
      #console.log "worker received raw msg"
      cb JSON.parse msg

  size = options.size ? 10
  max_iterations = options.max_iterations ? 2
  update_frequency = options.update_frequency ? 1.sec

  malloc = (N, f = -> 0) -> {inputs: [], value: f()} for i in [0...N]

  memory = malloc size, -> 0.0 # Math.random() # 0
 
  mpick = -> pick memory
  mget = (i) -> memory[i]
  mrindex = -> Math.round(Math.random() * (memory.length - 1))
  
  iterations = 0


  update: ->

    console.log "computing.."
    #console.log "memory: #{inspect memory, no, 3, yes}"

    for n in memory
      console.log "computing element"
      # add a new input
      if P mutable 0.20
        console.log "adding a new input"
        n.inputs.push mutable
          input: mrandindex() # TODO should not be *that* random
          weight: Math.random() * 0.01 + 1.0

      if n.inputs.length

        if P mutable 0.40
          console.log "deleting a random input"
          n.inputs.splice Math.round(Math.random() * n.inputs.length), 1

        # update an input weight
        if P mutable 0.30
          console.log "updating an input weight"
          input = n.inputs[(n.inputs.length - 1) * Math.random()]
          input.weight = mutable input.weight * 1.0

        # compute local state using some inputs
        if P mutable 0.95
          console.log "computing local state"
          n.value = 0
          for i in n.inputs
            input_signal = mget(i.input).value
            n.value += mutable input_signal * i.weight
          if n.inputs.length > 0
            n.value = n.value / n.inputs.length
            

      # done
    console.log "iteration #{++iterations} completed."

    if iterations >= max_iterations 
      console.log "stats: "
      console.log "  #{memory.length} in memory"
      console.log "  #{iterations} iterations"
      return
    else
      wait(update_frequency) -> compute()


  console.log "sending hello world"
  outputs hello: 'world'

  # start listening to incoming messages
  inputs (msg) ->
    console.log "master sent us #{inspect msg}"
    genome = msg.genome

    if genome?

      # default values of I/O variables
      mutation_rate = 0.05   
      forking_rate  = 0.60
      lifespan_rate = 0.01

      #  intenal (local) variables
      foo = 0.25  

      # TODO should be the same shit
      eval genome.src # run the evolvable kernel
      update()

      mutation_rate = Math.abs mutation_rate
      lifespan_rate = Math.abs lifespan_rate
      forking_rate  = Math.abs forking_rate
      
      # eve is not killed until we fully bootstrapped the system
      # maybe it's optional, since there will die after all,
      # and we can achieve the same by stopping forking
      if genome.generation > 0 and Math.random() < lifespan_rate
        outputs die: "end of tree"

      if Math.random() < forking_rate 
        #console.log "cloning"
        evolve.clone
          ratio: mutation_rate
          src: genome.src
          onComplete: (new_src) ->
            #console.log "sending back a new src to master"
            outputs
              record:
                id: makeId()
                generation: genome.generation + 1
                hash: sha1 new_src
                src: new_src
                stats: { mutation_rate, lifespan_rate, forking_rate }
            process.exit 0
      else
        process.exit 0
    else
      err = "error, unknow message: #{inspect msg}"
      console.log err
      process.exit 1


  start: =>

    # better to avoid @ in the loop
  
    frequency  = @frequency
    environment  = @environment

    sync = (f) => wait(@frequency) => @stats.update() ; f()

    iterations = 0
    do _ = => sync =>
      iterations += 1
      debug "iteration ##{iterations}: #{@agents.length} agents remaining"
      @agents = for agent in @agents
        #debug "going to process agent #{agent}"
        debug "preparing input data"
        inputs = environment.input {}, agent
        debug "running update function on inputs: "+ pretty inputs
        outputs = {}
        try
          outputs = agent.update inputs
        catch e1
          debug "killing agent (bad update function: #{e1})"
          continue
        try
          environment.output @stats, {}, agent, outputs
        catch e2
          debug "killing agent (bad output: #{e2})"
          continue
        agent
  
      _()

  decimate: =>
    debug "stats: #{inspect @stats}"



    @frequency = options.frequency ? 1000
    stats = options.stats ? { energy: (agent) -> agent.energy }

    @nbWorkers = options.workersByMachine ? common.NB_CORES

    @decimationTrigger = options.decimationTrigger ? 10


    @agents = []
    if options.agents?
      _agents = options.agents
      _agents = _agents() if isFunction _agents
      @agents = for agent in _agents
        data =
          update: ->
        for k, v of agent
          if k is 'update'
            data.update = if isFunction v then v else eval v
          else
            data[k] = v
        data

    @stats = new Stats @, stats
  
  start: =>

    # better to avoid @ in the loop
  
    frequency  = @frequency
    environment  = @environment

    sync = (f) => wait(@frequency) => @stats.update() ; f()

    iterations = 0
    do _ = => sync =>
      iterations += 1
      debug "iteration ##{iterations}: #{@agents.length} agents remaining"
      @agents = for agent in @agents
        #debug "going to process agent #{agent}"
        debug "preparing input data"
        inputs = environment.input {}, agent
        debug "running update function on inputs: "+ pretty inputs
        outputs = {}
        try
          outputs = agent.update inputs
        catch e1
          debug "killing agent (bad update function: #{e1})"
          continue
        try
          environment.output @stats, {}, agent, outputs
        catch e2
          debug "killing agent (bad output: #{e2})"
          continue
        agent
  
      _()

  decimate: =>
    debug "stats: #{inspect @stats}"


