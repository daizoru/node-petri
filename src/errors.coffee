defaultLogger = (value,msg='') ->
  console.log "#{value} points error: #{msg}"
module.exports = (onUpdate = defaultLogger) =>
  trivial : (msg='') -> onUpdate    10, msg
  minor   : (msg='') -> onUpdate    50, msg
  medium  : (msg='') -> onUpdate   500, msg
  major   : (msg='') -> onUpdate  5000, msg
  critical: (msg='') -> onUpdate 10000, msg
  fatal   : (msg='') -> throw new Error "fatal error: #{msg}"