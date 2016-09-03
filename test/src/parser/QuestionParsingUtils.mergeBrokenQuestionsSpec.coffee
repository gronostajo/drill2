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
    expect(result).toBeArrayOfSize(3)
    referenceQuestion = create.validQuestion()
    for question in result
      expect(question).toEqualQuestion(referenceQuestion)

  it 'should merge question without answers with question without body', ->
    result = @fn [
      create.questionWithoutAnswers('Qwerty')
      create.questionWithoutBody()
    ]
    expect(result).toBeArrayOfSize(1)
    expect(result[0]).toEqualQuestionDetails(create.questionWithoutAnswers('Qwerty'))
    expect(result[0]).toEqualAnswers(create.questionWithoutBody())

  it 'should merge any question with question without body', ->
    result = @fn [
      create.validQuestion('Qwerty', 1)
      create.questionWithoutBody(2)
    ]
    expect(result).toBeArrayOfSize(1)
    expect(result[0]).toEqualQuestionDetails(create.validQuestion('Qwerty', 1))
    expect(result[0].answers[0..0]).toEqualAnswers(create.validQuestion('Qwerty', 1).answers)
    expect(result[0].answers[1..]).toEqualAnswers(create.questionWithoutBody(2).answers)

  it 'should merge question with multiple questions without body', ->
    result = @fn [
      create.validQuestion('Qwerty', 1)
      create.questionWithoutBody(1)
      create.questionWithoutBody(2)
    ]
    expect(result).toBeArrayOfSize(1)
    expect(result[0]).toEqualQuestionDetails(create.validQuestion('Qwerty', 1))
    expect(result[0].answers[0..0]).toEqualAnswers(create.validQuestion('Qwerty', 1).answers)
    expect(result[0].answers[1..1]).toEqualAnswers(create.questionWithoutBody(1).answers)
    expect(result[0].answers[2..]).toEqualAnswers(create.questionWithoutBody(2).answers)

  it 'should leave question after a broken one untouched', ->
    result = @fn [
      create.validQuestion('Qwerty', 1)
      create.questionWithoutBody(1)
      create.validQuestion()
    ]
    expect(result).toBeArrayOfSize(2)
    expect(result[1]).toEqualQuestion(create.validQuestion())

  it 'should not affect further valid questions if first one has no body', ->
    result = @fn [
      create.questionWithoutBody()
      create.validQuestion()
    ]
    expect(result).toBeArrayOfSize(2)
    expect(result[0]).toEqualQuestion(create.questionWithoutBody())
    expect(result[1]).toEqualQuestion(create.validQuestion())

  it 'should merge two questions without bodies', ->
    result = @fn [
      create.questionWithoutBody()
      create.questionWithoutBody()
      create.validQuestion()
    ]
    expect(result).toBeArrayOfSize(2)
    expect(result[0]).toEqualQuestionDetails(create.questionWithoutBody())
    expect(result[0].answers[0..1]).toEqualAnswers(create.questionWithoutBody().answers)
    expect(result[0].answers[2..3]).toEqualAnswers(create.questionWithoutBody().answers)
    expect(result[1]).toEqualQuestion(create.validQuestion())

  it 'should merge two questions without answers', ->
    result = @fn [
      create.questionWithoutAnswers()
      create.questionWithoutAnswers()
      create.questionWithoutBody()
    ]
    expect(result).toBeArrayOfSize(1)
    referenceQuestion = create.questionWithoutAnswers()
    expect(result[0].body).toEqual(referenceQuestion.body + '\n\n' + referenceQuestion.body)
    expect(result[0].answers).toEqualAnswers(create.questionWithoutBody().answers)

  it 'should merge two questions without answers and two question without bodies', ->
    result = @fn [
      create.questionWithoutAnswers()
      create.questionWithoutAnswers()
      create.questionWithoutBody()
      create.questionWithoutBody()
    ]
    expect(result).toBeArrayOfSize(1)
    referenceQuestion = create.questionWithoutAnswers()
    referenceAnswers = create.questionWithoutBody().answers
    expect(result[0].body).toEqual(referenceQuestion.body + '\n\n' + referenceQuestion.body)
    expect(result[0].answers[0..1]).toEqualAnswers(referenceAnswers)
    expect(result[0].answers[2..3]).toEqualAnswers(referenceAnswers)

  it 'should leave last question without answers untouched', ->
    result = @fn [
      create.validQuestion()
      create.questionWithoutAnswers()
    ]
    expect(result).toBeArrayOfSize(2)
    expect(result[0]).toEqualQuestion(create.validQuestion())
    expect(result[1]).toEqualQuestion(create.questionWithoutAnswers())

  it 'should log nothing for valid questions', ->
    log = []
    @fn [
      create.validQuestion()
      create.validQuestion()
      create.validQuestion()
    ], (msg) -> log.push(msg)
    expect(log).toBeArrayOfSize(0)

  it 'should log that broken questions were fixed', ->
    log = []
    @fn [
      create.validQuestion()
      create.questionWithoutAnswers()
      create.questionWithoutBody()
    ], (msg) -> log.push(msg)
    expect(log).toBeArrayOfSize(1)
