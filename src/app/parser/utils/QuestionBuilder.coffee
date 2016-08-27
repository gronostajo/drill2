angular.module('DrillApp').service 'QuestionBuilder', (Question) ->
  class QuestionBuilder
    identifier: null
    bodyLines: null
    question: null
    answer:
      lines: []
      correct: null
      identifier: null

    constructor: ->
      @bodyLines = []

    setIdentifier: (identifier) ->
      if @identifier?
        throw new Error('Identifier already set')
      @identifier = identifier
      @

    appendBodyLine: (line) ->
      if @question?
        throw new Error('Answers already appended')
      @bodyLines.push(line)
      @

    _buildQuestion: ->
      @question = new Question(@bodyLines.join('\n\n'), @identifier)

    _pushAnswer: ->
      answerBody = @answer.lines.join('\n')
      @question.addAnswer(answerBody, @answer.correct, @answer.identifier)
      @answer.lines = []

    addAnswer: (line, correct, identifier) ->
      if not @question?
        @_buildQuestion()
      else if @answer.lines.length
        @_pushAnswer()
      @answer.lines.push(line.trim())
      @answer.correct = correct
      @answer.identifier = identifier
      @

    appendAnswerLine: (line) ->
      if not @answer.lines.length
        throw new Error('Answer not created yet')
      @answer.lines.push(line.trim())
      @

    build: ->
      if not @question?
        @_buildQuestion()
      else if @answer.lines.length
        @_pushAnswer()
      @question
