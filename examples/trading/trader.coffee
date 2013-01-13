
module.exports = (options={}) ->

  path                 = require 'path'
  colors               = require 'colors'
  geekdaq              = require 'geekdaq'
  {wait,repeat}        = require 'ragtime'
  {mutable, clone}     = require 'evolve'
  substrate            = require 'substrate'
  {P, copy, pretty}    = substrate.common
  byluck = P
  {failure, alert, success, info, debug} = @logger

  #demoDir = path.normalize "#{__dirname}/../examples/trading/"
  #console.log "modules: #{demoDir}"
  Market = require 'market'

  #################
  # MOCK NEWSFEED #
  #######################################################
  # TODO this should follow the twitter's search syntax #
  #######################################################
  keywords = ['fruits']
  news =
    latest: ->
      for i in [1..5]
        "pear #{if P 0.5 then 'is hipe' else 'sucks'}"


  #################
  # ROBOT ACCOUNT #
  #################
  account =
    username : 'test'
    portfolio: options.portfolio ? {}
    balance  : options.balance   ? 0
    history  : options.history   ? []

  ########################
  # VIRTUAL STOCK MARKET #
  ####################################################################
  # For the moment we use a random market which is just for debug    #
  # since it doesn't follow any realistic model/rules                #
  ####################################################################
  market = new Market 
    server: 'geekdaq'
    updateInterval: options.geekdaq.updateInterval
    commissions:
      buy: options.geekdaq.commissions.buy
      sell: options.geekdaq.commissions.sell
    tickers: options.geekdaq.tickers
    accounts: [ account ]
  
  # LISTEN TO DEBUG EVENTS FROM THE VIRTUAL MARKET
  market.on 'debug', (msg) ->
    debug msg.grey

  #############
  # PENALTIES #
  ####################################################################
  # The agent will have to pay for its bugs - this way it should     #
  # converge to more efficient solutions, evolving to have less bugs #
  ####################################################################
  energyModel =
    # PENALTIES
    NOT_ENOUGH_MONEY: -5
    NOT_IN_PORTFOLIO: -10
    NOT_ENOUGH_SHARES: -20


    # COSTS
    FORKING: -10
    BID: -10

    # REWARDS
    BENEFIT: +10

  # LISTEN TO ERRORS, APPLY PENALTY FOR CRITICAL ERRORS
  # BY REMOVING ##MO#N#E#Y## ENERGY FROM THE AGENT'S BALANCE
  market.on 'error', (code, msg) =>
    @transfert energyModel[code]
    #market.transfert account.username, energyModel[code]
    alert msg.red

  # start the update loop (generate the timeserie)
  market.start()

  # robots that have this balance will never die
  # that why it should be set quite high
  BEST_BALANCE = 100000

  # we count the iterations: this is used by the decimation process
  iterations = 0

  # an iteration 
  do main = =>

    ##########
    # ENERGY #
    ##########
    # Comptue how much energy should be put in the agent



    # SHARING #
    # energy can be shared among individuals



    #############################
    # TAXES AND RANDOM EXPENSES #
    ################################################################
    # By simulating random expenses and taxes, we give no "rest"   #
    # to the agents, so they will always have to seek new money    #
    # without limit (wealthy agents will have more taxes/expenses) #
    ################################################################
    
    ###################
    # WORLD WIDE NEWS #
    ###################
    latestNews = news.latest()

    ################
    # REPRODUCTION #
    ################################################################
    # Altough all the code can be mutated, since we choose to have #
    # the environment and the algorithm in the same source file,   #
    # we use the 'mutable' tag to only mutate parts of the code    #
    ################################################################

    if byluck mutable 0.50
      if @transfert energyModel.FORKING
        debug "reproducing"
        clone 
          src       : @source
          ratio     : 0.01
          iterations:  2
          onComplete: (src) ->
            debug "sending fork event"
            performance = 100
            @emit fork:
              src: src
              performance: performance
            wait(2000) -> process.exit 0
    
    ###################
    # BUY/SELL STOCKS #
    #####################################################################
    # The actual buy/sell process is not implemented yet, so we just do #
    # random things - but this is a top priority for later!             #
    #####################################################################
    orders = []
    if byluck mutable 1.0
      if @transfert energyModel.BID
        tick = 'PEAR' # yeah fixed ticker - as I said, it's just a test
        ticker = market.ticker tick
        price = ticker.price
        volume = ticker.volume
        orders.push
          type: if byluck(mutable 0.5) then 'buy' else 'sell'
          ticker: tick
          amount: mutable 100
          price: price

    # ask the market to execute our orders
    market.execute 
      username: account.username
      orders: orders
      onComplete: (err) =>
        wait(options.interval) main
  {}