angular.module('DrillApp').service 'Answer', ->
  class Answer
    constructor: (body, correct, @id) ->
      @body = body.trim()
      @correct = !!correct
      @checked = false

    append: (line) ->
      @body += '\n\n' + line.trim()
