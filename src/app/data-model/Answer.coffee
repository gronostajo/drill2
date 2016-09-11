angular.module('DrillApp').service 'Answer', ->
  class Answer
    constructor: (body, correct, @id) ->
      @body = body.trim()
      @correct = !!correct
      @checked = false

    append: (line) ->  # TODO is this used anywhere?
      @body += '\n\n' + line.trim()

    toString: ->
      if @correct
        "> #{@id}) #{@body}\n"
      else
        "  #{@id}) #{@body}\n"
