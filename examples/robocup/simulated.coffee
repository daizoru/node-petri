# STANDARD NODE LIB
{inspect} = require 'util'

# THIRD-PARTIES
SimSpark = require 'simspark'

# CUSTOM UTILITY FUNCTIONS
pretty = (obj) -> "#{inspect obj, no, 20, yes}"


# we keep tracks of the major game variables
state = {}

# we store game data in the "coach's journal"
maxJournal = 50
journal = []

# CONNECT TO SIMULATION SERVER
sim = new SimSpark "localhost"

sim.on 'connect', ->
  console.log "connected! sending messages.."

  # SEND INITIALIZATION DATA TO SIMULATION
  sim.send [
    ["scene", "rsg/agent/nao/nao.rsg"]
    ["init", 
      ["unum", 0], # sending 0 asks the server to attribute a random number
      ["teamname", "Daizoru"]]
  ]

  # beam effector, to position a player
  #sim.send ['beam', 10.0, -10.0, 0.0 ]

# RECEIVE DATA FROM SIMULATION
sim.on 'data', (events) ->
  console.log "received new events.."
  # we intercept special/important events, to know when to stop
  for p in events
    if p[0] in ['GS','AgentState']
      for kv in p[1..]
        state[kv[0]] = kv[1]

  # ADD TO THE GAME EVENTS JOURNAL
  journal.unshift events
  journal.pop() if journal.length > maxJournal

  # DEBUG
  console.log pretty state

# SERVER DIED OR DISCONNECTED US
sim.on 'end', -> console.log "disconnected from server"

# DEFINITION OF THE CONNECTOR / INTERFACE 
# the agent may be kept unchanged, yet its environment
# can change - eg "dev", "simulation" or "production" envs.
# that's why inputs and outputs are kept separated
# you may have many implementations of theses
module.exports =

  # INPUT (PRE-PROCESSOR)
  # This function prepare the input fed to the agent's update function
  # here we choose to ignore pre-defined inputs (eg. agent state)
  input: (shared, agent) -> # for now we don't care about the player ID, assume we only have 1
    { agent, journal }
 
  # OUTPUT (POST-PROCESSOR)
  # this function read the output of the update function
  # and update the environment
  output: (stats, shared, agent, outputs) ->

    # TODO 
    out = []

    #out.push ['lae3', 5.3]

    # hello world
    out.push ['say', "hello world"]

    out.push ['syn'] # sync agent mode - ignored if server is in RT mode

    sim.send out
