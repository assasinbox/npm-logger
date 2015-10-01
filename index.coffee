winston = require('winston')
Mail = require('winston-mail').Mail
config = require('../../config.json').log

levelOptions = {}
levelOptionsColors = {}
(levelOptions[item.name] = index) for item, index in config.levels
(levelOptionsColors[item.name] = item.color) for item in config.levels
winston.addColors(levelOptionsColors)

formatter = (options) ->
  JSON.stringify
    '@timestamp': Date.toISOString()
    '@fields':
      'AppType': config.appType
      'AppName': config.appName
      'ServerName': config.serverName
      'Severity':
        'name': options.level
        'code': levelOptions[options.level]
      'Debug':
        'message': options.message
        'trace': if options.meta.trace then options.meta.trace else {}
        'stack': if options.meta.stack then options.meta.stack else {}
        'os': if options.meta.os then options.meta.os else {}
        'process': if options.meta.process then options.meta.process else {}

transports = []
exceptionHandlers = []

for transportName, transportOptions of config.transports
  if transportOptions.enable
    delete transportOptions.enable
    if transportOptions.formatter then transportOptions.formatter = formatter else delete transportOptions.formatter
    transports.push(new (winston.transports[transportName])(transportOptions))

for exceptionHandlerName, exceptionHandlerOptions of config.exceptionHandlers
  if exceptionHandlerOptions.enable
    delete exceptionHandlerOptions.enable
    if exceptionHandlerOptions.formatter then exceptionHandlerOptions.formatter = formatter else delete exceptionHandlerOptions.formatter
    exceptionHandlers.push(new (winston.transports[exceptionHandlerName])(exceptionHandlerOptions))

logger = new (winston.Logger)(
  levels: levelOptions
  transports: transports
  exceptionHandlers: exceptionHandlers
  exitOnError: config.exitOnError
)

module.exports = logger