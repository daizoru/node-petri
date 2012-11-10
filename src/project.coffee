module.exports = (foo='bar') ->
  job: 0
  map: (N) -> foo: 'bar'
  reduce: (job, {foo}) ->
  stats: -> job_status: "0"