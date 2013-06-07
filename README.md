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

# common contains a collection of useful functions
# some do magic stuff, like extending Number's prototype
{every, pick} = common

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

## Documentation

### List of utility fonctions in petri/common:

#### after(timeunit(function))

This function execute a block of code after T time units.

Has to be used together with a magic Number, like this:

```coffeescript
after 5.min ->
  console.log "game over"
```

#### every(timeunit(function))

This function execute a block of code every T time units.

Has to be used together with a magic Number, like this:

```coffeescript
every 3.sec ->
  console.log "checkpoint!"
```

#### Magic Number

Here is the list of supported magic time units:

 - .ms
 - .sec, .second, .seconds
 - .min, .minute, .minutes
 - .hour, .hours
 - .day, .days

 Tell me if you need more pre-built units

#### MakeId()

This function generate a unique random id. 
Warning:: it sucks. You should probably use node-uuid instead.
But this is enough for basic debug cases

#### copy(obj)

Copy an object, using a JSON dump then parse.
This is not efficient, I will try to remplace it with node-v8-clone, which is more efficient

#### P(x)

Probability of something. Examole:

 - P(1.0) will always return 1
 - P(0.8) will return 1 most of the time
 - P(0.5) will return 1 or 0, with 50/50 chance
 - P(0.0) will always return 0

It does not return true or false, but 1 or 0,
so you can use it to do fuzzy (probabilistic) programming,
with inference rules and other things like that. Have fun.

Usage:

```coffeescript
if P 0.5
  console.log "A"
else
  console.log "B"
```

#### isFunction(something)

Stolen from underscore.js. Check if something is a Function


#### isUndefined(something)

Stolen from underscore.js. Check if something is undefined



#### isArray(something)

Stolen from underscore.js. Check if something is a true Array (eg. a String will return false)


#### isString(something)

Stolen from underscore.js. Check if something is a String


#### isNumber(something)

Stolen from underscore.js. Check if something is a Number


#### isBoolean(something)

Stolen from underscore.js. Check if something is a Boolean

#### randInt(min, max)

Random integer between min and max. Integer means: rounded.

#### round2(number)

Helper function to round a number to 2 decimals

#### round3(number)

Helper function to round a number to 3 decimals (yeah..)

#### sha1(string)

Compute the sha1 *synchronously*. Be warned.

#### NB_CORES

A constant indicating the number of core you can use to spawn workers.
This function has an heuristic to save CPU by not counting the base core, see below.

Implementation:
```coffeescript
cpus = Math.round(os.cpus().length)
if (cpus < 3) then 1 else (cpus - 2)
``` 

#### pick(weighted_key_value_store)

Stolen from node-deck. This function picks a random item from a weighted index,
see example:

```coffeescript
store =
  key1: 50
  key2: 200
  key3: 10

key = pick store 
# most of the time, key2 will be extracted, sometimes key1, rarely key3
```

#### pretty obj

Prettify an object to make it human-readable.
Equavalent to "inspect(obj, false, 20, true).toString()""

#### readFile(file_path)

Read the content of a file *synchronously*.
Useful for simple command line script, than don't need to be async.

equivalent to: "fs.readFileSync(file_path, 'utf8')"

