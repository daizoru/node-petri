substrate = require 'substrate'

system = substrate.System

  bootstrap: [ 
    (master, options={}) -> master.send options
  ]

  workersByMachine: 1
  decimationTrigger: 1000

  config: (agent) ->
    test: "done"

callbacks = 
  message: ->
  error: ->
  
system.on 'message', (msg) -> callbacks.message msg
system.on 'error',   (msg) -> callbacks.error   msg

describe 'System()', ->
  it 'should work for a symbol agent and event', (done) ->
    callbacks.message = (msg) ->
      if msg.test is 'done'
        done()