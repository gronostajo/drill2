describe 'QuestionParsingUtils.removeInvalidQuestions', ->
  create = {}

  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (QuestionParsingUtils, Question) ->
      @fn = QuestionParsingUtils.removeInvalidQuestions

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

  it 'should not remove regular questions', ->
    log = []
    result = @fn [
      create.validQuestion()
      create.validQuestion()
      create.validQuestion()
    ], (msg) -> log.push(msg)

    expect(result).toBeArrayOfSize(3)
    referenceQuestion = create.validQuestion()
    for question in result
      expect(question).toEqualQuestion(referenceQuestion)
    expect(log).toBeEmptyArray()

  it 'should not remove questions with only valid answers', ->
    log = []
    question = create.validQuestion('Three valid answers', 3)
    answer.correct = yes for answer in question.answers

    result = @fn [
      question
    ], (msg) -> log.push(msg)

    expect(result).toBeArrayOfSize(1)
    referenceQuestion = create.validQuestion('Three valid answers', 3)
    answer.correct = yes for answer in referenceQuestion.answers
    expect(result[0]).toEqualQuestion(referenceQuestion)
    expect(log).toBeEmptyArray()

  it 'should remove question without body', ->
    log = []
    result = @fn [
      create.questionWithoutBody()
    ], (msg) -> log.push(msg)
    expect(result).toBeEmptyArray()
    expect(log).toBeArrayOfSize(1)

  it 'should remove question with no answers', ->
    log = []
    result = @fn [
      create.questionWithoutAnswers()
    ], (msg) -> log.push(msg)
    expect(result).toBeEmptyArray()
    expect(log).toBeArrayOfSize(1)

  it 'should remove question with one answer', ->
    log = []
    result = @fn [
      create.validQuestion('Whatever', 1)
    ], (msg) -> log.push(msg)
    expect(result).toBeEmptyArray()
    expect(log).toBeArrayOfSize(1)

  it 'should remove question with no correct answers', ->
    log = []
    question = create.validQuestion()
    answer.correct = no for answer in question.answers

    result = @fn [
      question
    ], (msg) -> log.push(msg)
    expect(result).toBeEmptyArray()
    expect(log).toBeArrayOfSize(1)

  it 'should not affect valid questions around invalid ones', ->
    log = []
    result = @fn [
      create.validQuestion()
      create.questionWithoutAnswers()
      create.questionWithoutBody()
      create.validQuestion()
    ], (msg) -> log.push(msg)

    expect(result).toBeArrayOfSize(2)
    referenceQuestion = create.validQuestion()
    for question in result
      expect(question).toEqualQuestion(referenceQuestion)
    expect(log).toBeArrayOfSize(2)

  it 'should not affect valid questions between invalid ones', ->
    log = []
    result = @fn [
      create.questionWithoutAnswers()
      create.validQuestion()
      create.questionWithoutBody()
    ], (msg) -> log.push(msg)

    expect(result).toBeArrayOfSize(1)
    expect(result[0]).toEqualQuestion(create.validQuestion())
    expect(log).toBeArrayOfSize(2)
