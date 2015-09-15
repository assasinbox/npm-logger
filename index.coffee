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
    '@timestamp': Date.now()
    '@fields':
      'AppType': config.appType
      'AppName': config.appName
      'ServerName': config.serverName
      'Severity':
        'name': options.level
        'code': levelOptions[options.level]
      'Server': {}
      'Debug':
        'message': options.message
      'User': {}

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