#!/usr/bin/env coffee

# STANDARD LIB
{inspect,log} = require 'util'
{puts} = require 'sys'

# THIRD PARTIES
# {foreach,map,reduce,delay,async,wait} = require 'ragtime'
timmy = require 'timmy'

# NODE-SUBSTRATE:
substrate = require 'substrate'

# - ERROR TOOLS
{trivial, minor, major} = substrate.errors

# - EVOLUTIONARY TOOLS
{mutate,mutable}  = substrate.evolve

# - MISC UTILS
{P, copy} = substrate.common


model = require './model'

main = ->
  system = new System

    # connect to an interface
    connector: require './simulated'

    # TODO maybe we don't need this?
    stats:
      #temp:    (agent) -> agent.temp
      battery: (agent) -> agent.battery


    # TODO WRITE THE UPDATE FUNCTION
    agents: []


  # WORKFLOW:

  # 1. run the rcssserver3d

  # 2. run the monitor?

  # 3. run this:
  system.start()

  #. 4. "blow the whistle"
  # in monitor: press K to kick off and start the first period of the game. 
  # The game time will start counting up and the play mode will change from 
  # BeforeKickOff to KickOff. Game on!
