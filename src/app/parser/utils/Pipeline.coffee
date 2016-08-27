angular.module('DrillApp').service 'Pipeline', ->
  class Pipeline
    log: []

    constructor: (@data) ->
      return

    _logAppender: (str) =>
      @log.push(str)

    apply: (func) ->
      @data = func(@data, @_logAppender)
      @

    map: (func) ->
      throw new Error('Pipeline content is not an array') if not angular.isArray(@data)
      @data = (func(item, @_logAppender) for item in @data)
      @

    get: -> @data

    getLog: -> @log[..]
