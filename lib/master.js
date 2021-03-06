// Generated by CoffeeScript 1.6.3
(function() {
  var Master, Stream, cluster, inspect, pretty, sha1, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  inspect = require('util').inspect;

  cluster = require('cluster');

  Stream = require('stream');

  _ref = require('./common'), pretty = _ref.pretty, sha1 = _ref.sha1;

  Master = (function(_super) {
    __extends(Master, _super);

    function Master(main) {
      var actions, callbacks, emit, log,
        _this = this;
      this.isMaster = true;
      emit = function(key, msg) {
        return _this.emit(key, msg);
      };
      log = function(name, msg) {
        return console.log("" + name + ": " + msg);
      };
      callbacks = {
        onReady: function() {},
        onExit: function() {},
        onData: function() {}
      };
      actions = {
        spawn: function(src, params) {
          var agent, worker;
          worker = cluster.fork();
          agent = {};
          agent.src = src.toString();
          agent.sha = sha1(agent.src);
          agent.name = ("" + agent.sha).slice(-8);
          agent.slot = worker.id;
          worker.agent = agent;
          worker.on('message', function(raw) {
            var msg, reply;
            msg = JSON.parse(raw);
            switch (msg.cmd) {
              case 'ready':
                return worker.send(JSON.stringify({
                  cmd: 'spawn',
                  agent: worker.agent,
                  params: params
                }));
              case 'ping':
                return log(worker.agent.name, "PING worker is still alive");
              case 'failure':
                return log(worker.agent.name, ("FAILURE " + msg.msg).red);
              case 'warn':
                return log(worker.agent.name, ("WARNING " + msg.msg).yellow);
              case 'success':
                return log(worker.agent.name, ("SUCCESS " + msg.msg).green);
              case 'info':
                return log(worker.agent.name, "INFO " + msg.msg);
              case 'debug':
                return log(worker.agent.name, ("DEBUG " + msg.msg).grey);
              default:
                reply = function(msg) {
                  return worker.send(JSON.stringify(msg));
                };
                return callbacks.onData(reply, worker.agent, msg);
            }
          });
          worker.die = function(msg) {
            return worker.send(JSON.stringify({
              die: msg
            }));
          };
          return worker;
        },
        broadcast: function(msg) {
          var id, _i, _len, _ref1, _results;
          console.log("debug: broadcasting..");
          _ref1 = cluster.workers;
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            id = _ref1[_i];
            _results.push(cluster.workers[id].send(JSON.stringify(msg)));
          }
          return _results;
        }
      };
      cluster.on("exit", function(worker, code, signal) {
        return callbacks.onExit(worker.agent, code, signal);
      });
      main.apply({
        'on': function(event, cb) {
          switch (event) {
            case 'exit':
              return callbacks.onExit = cb;
            case 'data':
              return callbacks.onData = cb;
            case 'ready':
              return callbacks.onReady = cb;
          }
        },
        spawn: actions.spawn,
        broadcast: actions.broadcast
      });
    }

    return Master;

  })(Stream);

  module.exports = function(onReady) {
    return new Master(onReady);
  };

}).call(this);
