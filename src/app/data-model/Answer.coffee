angular.module('DrillApp').service 'Answer', ->
  class Answer
    constructor: (body, correct, @id) ->
      @body = body.trim()
      @correct = !!correct
      @checked = false

    toString: ->
      if @correct
        "> #{@id}) #{@body}\n"
      else
        "  #{@id}) #{@body}\n"
