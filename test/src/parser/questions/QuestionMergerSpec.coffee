describe 'QuestionMerger', ->
  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (@QuestionMerger, @QuestionBuilder) ->
      @question1 = new @QuestionBuilder()
      .setIdentifier('one')
      .appendToBody('first')
      .addAnswer('answer 1', yes, 'x')
      .addAnswer('answer 2', no, 'y')
      .build()
      @question2 = new @QuestionBuilder()
      .setIdentifier('two')
      .appendToBody('second')
      .addAnswer('answer 3', yes, 'a')
      .addAnswer('answer 4', no, 'b')
      .build()

  it 'should merge questions', ->
    referenceQuestion = new @QuestionBuilder()
    .setIdentifier(@question1.id)
    .appendToBody(@question1.body)
    .appendToBody(@question2.body)
    .addAnswers(@question1.answers)
    .addAnswers(@question2.answers)
    .build()
    expect(@QuestionMerger.merge(@question1, @question2)).toEqualQuestion(referenceQuestion)

  it 'should skip empty bodies', ->
    answersOnlyQuestion = new @QuestionBuilder()
    .addAnswer('answer X', yes, 'k')
    .addAnswer('answer Y', no, 'l')
    .build()
    referenceQuestion = new @QuestionBuilder()
    .setIdentifier(@question1.id)
    .appendToBody(@question1.body)
    .addAnswers(@question1.answers)
    .addAnswers(answersOnlyQuestion.answers)
    .build()
    expect(@QuestionMerger.merge(@question1, answersOnlyQuestion)).toEqualQuestion(referenceQuestion)

  it 'should not use second question\'s ID when merging', ->
    noIdQuestion = new @QuestionBuilder()
    .appendToBody('whatever')
    .addAnswer('answer X', yes, 'k')
    .addAnswer('answer Y', no, 'l')
    .build()
    expect(@QuestionMerger.merge(noIdQuestion, @question2).id).toBeFalsy()
