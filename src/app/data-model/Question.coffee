angular.module('DrillApp').service 'Question', (Answer) ->
  class Question
    constructor: (@body = '', @id) ->
      @explanation = no
      @relatedLinks = []
      @answers = []
      @scoreLog = []

    addAnswer: (body, correct, id) ->
      answer = new Answer(body, correct, id)
      @answers.push(answer)

    # TODO remove this in favor of QuestionBuilder
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

    grade: (graderFunction) =>
      grade = graderFunction(@)
      time = if @.timeLeft? then @timeLeft else 0

      @scoreLog.push
        score: grade.score
        total: grade.total
        timeLeft: time

      grade

    setExplanation: (explanation) ->
      @explanation = explanation
      @hasExplanations = yes

    setRelatedLinks: (links) ->
      @relatedLinks = links

    toString: (includeAnswers = yes) ->
      body = if @id? then "[##{@id}] #{@body}" else @body
      body = body.replace(/\n\n/g, '\n') + '\n'
      if includeAnswers
        for answer in @answers
          body += answer.toString()
      body
