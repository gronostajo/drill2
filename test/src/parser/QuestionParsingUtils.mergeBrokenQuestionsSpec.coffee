describe 'QuestionParsingUtils.mergeBrokenQuestions', ->
  create = {}

  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (QuestionParsingUtils, Question) ->
      @fn = QuestionParsingUtils.mergeBrokenQuestions

      create.validQuestion = (body = 'This is a valid question', answerCount = 2) ->
        q = new Question(body)
        for answerIndex in [1..answerCount]
          q.addAnswer("Answer ##{answerIndex}", answerIndex is 1, 'a')
        q
      create.questionWithoutAnswers = (body = 'This one has no answers') ->
        new Question(body)
      create.questionWithoutBody = (answerCount = 2) ->
        q = new Question()
        for answerIndex in [1..answerCount]
          q.addAnswer("Answer ##{answerIndex}", answerIndex is 1, 'a')
        q

  it 'should leave proper questions untouched', ->
    result = @fn [
      create.validQuestion()
      create.validQuestion()
      create.validQuestion()
    ]

    expect(result.length).toBe(3)
    referenceQuestion = create.validQuestion()
    for question in result
      expect(question.body).toEqual(referenceQuestion.body)
      expect(question.identifier).toEqual(referenceQuestion.identifier)
      expect(question.answers.length).toEqual(referenceQuestion.answers.length)
      expect(question.answers[0].body).toEqual(referenceQuestion.answers[0].body)
      expect(question.answers[0].correct).toBe(referenceQuestion.answers[0].correct)
      expect(question.answers[0].id).toEqual(referenceQuestion.answers[0].id)
      expect(question.answers[1].body).toEqual(referenceQuestion.answers[1].body)
      expect(question.answers[1].correct).toBe(referenceQuestion.answers[1].correct)
      expect(question.answers[1].id).toEqual(referenceQuestion.answers[1].id)

  it 'should merge question without answers with question without body', ->
    result = @fn [
      create.questionWithoutAnswers('Qwerty')
      create.questionWithoutBody()
    ]

    expect(result.length).toBe(1)
    expect(result[0].body).toEqual('Qwerty')
    expect(result[0].answers.length).toBe(2)
    expect(result[0].answers[0].body).toEqual('Answer #1')
    expect(result[0].answers[0].correct).toBe(true)
    expect(result[0].answers[1].body).toEqual('Answer #2')
    expect(result[0].answers[1].correct).toBe(false)

  it 'should merge any question with question without body', ->
    result = @fn [
      create.validQuestion('Qwerty', 1)
      create.questionWithoutBody(2)
    ]

    expect(result.length).toBe(1)
    expect(result[0].body).toEqual('Qwerty')
    expect(result[0].answers.length).toBe(3)
    expect(result[0].answers[0].body).toEqual('Answer #1')
    expect(result[0].answers[0].correct).toBe(true)
    expect(result[0].answers[1].body).toEqual('Answer #1')
    expect(result[0].answers[1].correct).toBe(true)
    expect(result[0].answers[2].body).toEqual('Answer #2')
    expect(result[0].answers[2].correct).toBe(false)

  it 'should merge question with multiple questions without body', ->
    result = @fn [
      create.validQuestion('Qwerty', 1)
      create.questionWithoutBody(1)
      create.questionWithoutBody(2)
    ]

    expect(result.length).toBe(1)
    expect(result[0].body).toEqual('Qwerty')
    expect(result[0].answers.length).toBe(4)
    expect(result[0].answers[0].body).toEqual('Answer #1')
    expect(result[0].answers[0].correct).toBe(true)
    expect(result[0].answers[1].body).toEqual('Answer #1')
    expect(result[0].answers[1].correct).toBe(true)
    expect(result[0].answers[2].body).toEqual('Answer #1')
    expect(result[0].answers[2].correct).toBe(true)
    expect(result[0].answers[3].body).toEqual('Answer #2')
    expect(result[0].answers[3].correct).toBe(false)

  it 'should leave question after a broken one untouched', ->
    result = @fn [
      create.validQuestion('Qwerty', 1)
      create.questionWithoutBody(1)
      create.validQuestion()
    ]

    expect(result.length).toBe(2)
    referenceQuestion = create.validQuestion()
    expect(result[1].body).toEqual(referenceQuestion.body)
    expect(result[1].identifier).toEqual(referenceQuestion.identifier)
    expect(result[1].answers.length).toEqual(referenceQuestion.answers.length)
    expect(result[1].answers[0].body).toEqual(referenceQuestion.answers[0].body)
    expect(result[1].answers[0].correct).toBe(referenceQuestion.answers[0].correct)
    expect(result[1].answers[0].id).toEqual(referenceQuestion.answers[0].id)
    expect(result[1].answers[1].body).toEqual(referenceQuestion.answers[1].body)
    expect(result[1].answers[1].correct).toBe(referenceQuestion.answers[1].correct)
    expect(result[1].answers[1].id).toEqual(referenceQuestion.answers[1].id)

  it 'should not affect further valid questions if first one has no body', ->
    input = [
      create.questionWithoutBody()
      create.validQuestion()
    ]
    expect(@fn(input)).toEqual(input)

  it 'should merge two questions without bodies', ->
    result = @fn [
      create.questionWithoutBody()
      create.questionWithoutBody()
      create.validQuestion()
    ]
    expect(result.length).toBe(2)
    expect(result[0].answers.length).toBe(4)

  it 'should leave last question without answers untouched', ->
    result = @fn [
      create.validQuestion()
      create.questionWithoutAnswers()
    ]

    expect(result.length).toBe(2)

    referenceValidQuestion = create.validQuestion()
    expect(result[0].body).toEqual(referenceValidQuestion.body)
    expect(result[0].identifier).toEqual(referenceValidQuestion.identifier)
    expect(result[0].answers.length).toEqual(referenceValidQuestion.answers.length)
    expect(result[0].answers[0].body).toEqual(referenceValidQuestion.answers[0].body)
    expect(result[0].answers[0].correct).toBe(referenceValidQuestion.answers[0].correct)
    expect(result[0].answers[0].id).toEqual(referenceValidQuestion.answers[0].id)
    expect(result[0].answers[1].body).toEqual(referenceValidQuestion.answers[1].body)
    expect(result[0].answers[1].correct).toBe(referenceValidQuestion.answers[1].correct)
    expect(result[0].answers[1].id).toEqual(referenceValidQuestion.answers[1].id)

    referenceQuestionWithoutAnswers = create.questionWithoutAnswers()
    expect(result[1].body).toEqual(referenceQuestionWithoutAnswers.body)
    expect(result[1].identifier).toEqual(referenceQuestionWithoutAnswers.identifier)
    expect(result[1].answers.length).toEqual(referenceQuestionWithoutAnswers.answers.length)

  it 'should log nothing for valid questions', ->
    log = []
    @fn [
      create.validQuestion()
      create.validQuestion()
      create.validQuestion()
    ], (msg) -> log.push(msg)
    expect(log.length).toBe(0)

  it 'should log that broken questions were fixed', ->
    log = []
    @fn [
      create.validQuestion()
      create.questionWithoutAnswers()
      create.questionWithoutBody()
    ], (msg) -> log.push(msg)
    expect(log.length).toBe(1)
