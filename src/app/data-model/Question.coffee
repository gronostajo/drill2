angular.module('DrillApp').service 'Question', (Answer) ->
  class Question
    constructor: (@body, @id) ->
      @explanation = no
      @answers = []
      @scoreLog = []

    addAnswer: (body, correct, id) ->
      answer = new Answer(body, correct, id)
      @answers.push(answer)

    appendToLastAnswer: (line) ->
      @answers[@answers.length - 1].append(line)

    countAnswers: (filter) ->
      count = 0
      for answer in @answers
        count++ if filter(answer)
      count

    totalCorrect: ->
      @countAnswers (answer) -> answer.correct

    correct: ->
      @countAnswers (answer) -> answer.checked and answer.correct

    incorrect: ->
      @countAnswers (answer) -> answer.checked and not answer.correct

    missed: ->
      @countAnswers (answer) -> not answer.checked and answer.correct

    grade: (graderFunction) ->
      grade = graderFunction(@)
      time = if @.timeLeft? then @timeLeft else 0

      @scoreLog.push
        score: grade.score
        total: grade.total
        timeLeft: time

      grade

    loadExplanation: (explanation) ->
      if explanation[@id]?
        @explanation = explanation[@id]
        @hasExplanations = yes
