angular.module('DrillApp').service 'Pipeline', ->
  class Pipeline
    constructor: (@data) ->
      @log = []

    _logAppender: (str) =>
      @log.push(str)

    apply: (func) ->
      @data = func(@data, @_logAppender)
      @

    map: (func) ->
      throw new Error('Pipeline content is not an array') if not angular.isArray(@data)
      @data = (func(item, @_logAppender) for item in @data)
      @

    filter: (func) ->
      throw new Error('Pipeline content is not an array') if not angular.isArray(@data)
      @data = @data.filter (item) => func(item, @_logAppender)
      @

    get: -> @data

    getLog: -> @log[..]
