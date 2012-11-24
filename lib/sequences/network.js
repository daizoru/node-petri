// Generated by CoffeeScript 1.4.0
(function() {
  var P, cluster, deck, inspect, makeId, map, mutable, mutate, pick, sha1, timmy, wait, _ref, _ref1, _ref2;

  cluster = require('cluster');

  inspect = require('util').inspect;

  deck = require('deck');

  _ref = require('ragtime'), map = _ref.map, wait = _ref.wait;

  _ref1 = require('evolve'), mutable = _ref1.mutable, mutate = _ref1.mutate;

  timmy = require('timmy');

  _ref2 = require('../common'), P = _ref2.P, makeId = _ref2.makeId, sha1 = _ref2.sha1, pick = _ref2.pick;

  (function() {
    var iterations, malloc, max_iterations, memory, mget, mpick, mrindex, size, update_frequency, _ref3, _ref4, _ref5;
    size = (_ref3 = options.size) != null ? _ref3 : 10;
    max_iterations = (_ref4 = options.max_iterations) != null ? _ref4 : 2;
    update_frequency = (_ref5 = options.update_frequency) != null ? _ref5 : 1..sec;
    malloc = function(N, f) {
      var i, _i, _results;
      if (f == null) {
        f = function() {
          return 0;
        };
      }
      _results = [];
      for (i = _i = 0; 0 <= N ? _i < N : _i > N; i = 0 <= N ? ++_i : --_i) {
        _results.push({
          inputs: [],
          value: f()
        });
      }
      return _results;
    };
    memory = malloc(size, function() {
      return 0.0;
    });
    mpick = function() {
      return pick(memory);
    };
    mget = function(i) {
      return memory[i];
    };
    mrindex = function() {
      return Math.round(Math.random() * (memory.length - 1));
    };
    iterations = 0;
    return {
      compute: function() {
        var i, input, input_signal, n, _i, _j, _len, _len1, _ref6;
        console.log("computing..");
        for (_i = 0, _len = memory.length; _i < _len; _i++) {
          n = memory[_i];
          console.log("computing element");
          if (P(mutable(0.20))) {
            console.log("adding a new input");
            n.inputs.push(mutable({
              input: mrandindex(),
              weight: Math.random() * 0.01 + 1.0
            }));
          }
          if (n.inputs.length) {
            if (P(mutable(0.40))) {
              console.log("deleting a random input");
              n.inputs.splice(Math.round(Math.random() * n.inputs.length), 1);
            }
            if (P(mutable(0.30))) {
              console.log("updating an input weight");
              input = n.inputs[(n.inputs.length - 1) * Math.random()];
              input.weight = mutable(input.weight * 1.0);
            }
            if (P(mutable(0.95))) {
              console.log("computing local state");
              n.value = 0;
              _ref6 = n.inputs;
              for (_j = 0, _len1 = _ref6.length; _j < _len1; _j++) {
                i = _ref6[_j];
                input_signal = mget(i.input).value;
                n.value += mutable(input_signal * i.weight);
              }
              if (n.inputs.length > 0) {
                n.value = n.value / n.inputs.length;
              }
            }
          }
        }
        console.log("iteration " + (++iterations) + " completed.");
        if (iterations >= max_iterations) {
          console.log("stats: ");
          console.log("  " + memory.length + " in memory");
          console.log("  " + iterations + " iterations");
        } else {
          return wait(update_frequency)(function() {
            return compute();
          });
        }
      }
    };
  });

}).call(this);