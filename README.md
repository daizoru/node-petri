#node-petri
===========

*a multi-agent system for Node*

## Description

For now this is mostly wrapper around Node Cluster, with some syntactic sugar

## Usage

(Illustration example - code not tested)

### Master (code controlling the pool, how agents are created)

```coffeescript
{Petri, common} = require 'petri'
{pretty, repeat, every, pick, sha1} = common

Petri ->
  console.log "Initializing"

  pool_size = 3
  pool = {}

  # initialize using the source code of a program
  pool["#{require('./SOME/SOURCE/FILE')}"] = 1

  @spawn() for i in [0...pool_size]

  # subscribe to the "agent died" event
  @on 'exit', (worker, src, code, signal) =>
    console.log "Agent terminated with exit code: #{code}"

    # spawn a new agent to remplace the dead one
    @spawn()

  # subscribe to the "agent is ready" event
  # agent that emit this event are uninitialized:
  # you have to call onComplete with a config
  @on 'ready', (onComplete) ->

    console.log "Agent ready, configuring.."

    onComplete

      # setting the source is mandatory
      # (it is used as an unique DNA-like identificator)
      src: pick pool

      # other stuff you want to pass to the agent
      foo: 'foo'
      bar: 'bar'

  # subscribe to the "agent is sending a message" event
  # 'reply' is a function you can use to reply to the agent
  @on 'data', (reply, src, packet) ->

    switch packet.cmd

      when 'log'
        console.log "#{packet.msg}"

      else
        console.log "unknow cmd #{pretty packet}"

  # some syntactic sugar for looping every 5 seconds
  # try it with other values like 200.ms or 1.min to see the changes
  every 5.sec =>

    console.log "broadcasting to all agents"
    
    @broadcast cmd: "foobar", data: "hello world"
```