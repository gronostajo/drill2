app = angular.module 'DrillApp'


app.factory 'AnswerFactory', ->
  createAnswer: (body, correct, id) ->

    Answer = (body, correct, id) ->
      @body = body.trim()
      @id = id
      @correct = !!correct
      @checked = false

      @append = (line) ->
        @body += '\n\n' + line.trim()

      return

    new Answer body, correct, id
