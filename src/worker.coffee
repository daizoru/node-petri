# standard library
cluster = require 'cluster'

# third parties libs
colors   = require 'colors'
npm      = require 'npm'

{P, makeId, sha1, pick, every, pretty, log, isString} = require './common'

module.exports = ->

  agent =
    sha: ''
    name: ''
    listeners: {}

  emit = (msg) -> process.send JSON.stringify msg
  
  onEvent = (signalKey, cb) ->
    listeners[signalKey] = (listeners[signalKey] ? []).push cb

  spawned = no

 
  npm.load npm.config, (npmErr) ->
    throw err if npmErr?

    npm.on "log", (message) -> emit cmd: 'debug', msg: message

    process.on 'message', (raw) -> 

      msg = JSON.parse raw
      #console.log "msg: #{pretty msg}"
      #console.log "msg.cmd: #{msg.cmd}"
      switch msg.cmd
        when 'die'
          emit cmd: 'warn', msg: 'master asked me to die'
          process.exit -1

        when 'spawn'
          #console.log "spawning.."
          for k,v of msg.agent
            continue if k is 'listeners'
            agent[k] = v

          unless agent.src
            emit cms: 'failure', msg: "no src found in params passed ot the spawn()"
            process.exit -1
          
          every 3.sec -> emit cmd: 'ping'

          run = (program, params) ->
            if isString program
              agent.src = program
            else
              agent.src = program.toString()

            context =
              emit: emit 
              src: agent.src
              #require: (x) -> emit cmd: 'warn', msg: "agent wants to require a module named '#{x}'"
              logger:
                failure: (msg) -> emit cmd: 'failure', msg: msg.toString()
                warn   : (msg) -> emit cmd: 'warn', msg: msg.toString()
                success: (msg) -> emit cmd: 'success', msg: msg.toString()
                info   : (msg) -> emit cmd: 'info', msg: msg.toString()
                debug  : (msg) -> emit cmd: 'debug', msg: msg.toString()

            if isString program
              eval "var Agent = #{src};"
              console.log "running #{pretty agent.name}"
              Agent.apply context, [params]
            else
              console.log "running #{pretty agent.name}"
              program.apply context, [params]
            #catch err
            #  console.log "failed: #{err}"
            #  context.logger.failure "#{err}"
            #  process.exit 2


          # let's see if the user is trying to load a constant (immutable) module
          download = (moduleName, cb, lastError=undefined) ->
            log "downloading #{moduleName}"
        
            try
              loaded = require "#{moduleName}"
              log "seems like requiring #{moduleName} worked. Cool."
              cb undefined
            catch error
              log "got error #{error}"
              if error is lastError
                cb error
                return
              # new error, let's try
              log "checking if this is a dependency problem.."
              match = /Cannot find module '([a-zA-Z0-9_\-\.]+)'/i.exec error.message
              if error.code is 'MODULE_NOT_FOUND'
                missingModule = match[1]
                log "yes it is.. installing #{missingModule} using NPM.."
                cb 1 ; return
                npm.commands.install [ missingModule ], (npmError, data) ->
                  if npmError?
                    log "npm install failed: " + pretty npmError
                    cb npmError
                  else
                    log "npm install succeeded"
                    download moduleName, cb, error
              else
                log "not a dependency issue: " + pretty error
                cb error, undefined

          match = /[a-zA-Z0-9\-_]+/i.exec agent.src
          if match?
            log "requiring module " + match[0]
            download match[0], (err) ->
              if err?
                throw err

              log "loading the module"
              loaded = require match[0]
              run loaded, msg.params
          else
            log "loading directly the source code"
            run agent.src, msg.params

        else
          for listener in (agent.listeners[msg.cmd] ? [])
            listener()

    emit cmd: 'ready'
