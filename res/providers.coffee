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


app.factory 'StatsFactory', ->
  createStats: ->

    Stats = ->
      @correct = 0
      @partial = 0
      @incorrect = 0
      @score = 0
      @totalPoints = 0

      @totalQuestions = ->
        @correct + @incorrect + @partial

      @pcOfQuestions = (num) ->
        if @totalQuestions() then Math.round (num * 100 / @totalQuestions()) else 0

      @pcScore = ->
        if @totalPoints then Math.round (@score * 100 / @totalPoints) else 0

      return

    new Stats()


app.factory 'ViewFactory', ->
  createView: ->

    View = ->
      @current = 'first'

      @isFirst = -> @current == 'first'
      @isNotGraded = -> @current == 'question'
      @isGraded = -> @current == 'graded'
      @isQuestion = -> @isGraded() or @isNotGraded()
      @isFinal = -> @current == 'end'

      return

    new View()