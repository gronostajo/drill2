app = angular.module 'DrillApp'


app.factory 'QuestionFactory', (AnswerFactory) ->
  createQuestion: (body, id) ->

    Question = (body, id) ->
      @body = body
      @id = id
      @explanation = false
      @answers = []
      @scoreLog = []

      @addAnswer = (body, correct, id) ->
        answer = AnswerFactory.createAnswer body, correct, id
        @answers.push answer

      @appendToLastAnswer = (line) ->
        @answers[@answers.length - 1].append line

      @totalCorrect = ->
        x = 0
        for answer in @answers
          x++ if answer.correct
        x

      @correct = ->
        x = 0
        for answer in @answers
          x++ if answer.checked and answer.correct
        x

      @incorrect = ->
        x = 0
        for answer in @answers
          x++ if answer.checked and not answer.correct
        x

      @missed = ->
        x = 0
        for answer in @answers
          x++ if not answer.checked and answer.correct
        x

      @grade = (grader) ->
        grade = grader this
        time = if @hasOwnProperty 'timeLeft' then @timeLeft else 0

        @scoreLog.push
          score: grade.score
          total: grade.total
          timeLeft: time

        grade

      @loadExplanation = (expl) ->
        if expl.hasOwnProperty @id
          @explanation = expl[@id]
          @hasExplanations = true

      return

    new Question body, id
