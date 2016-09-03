describe 'QuestionBuilder', ->
  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (@QuestionBuilder, @Answer) ->

  it 'should create simple questions', ->
    builder = new @QuestionBuilder()
    builder.appendToBody('Hello world')
    question = builder.build()
    expect(question.body).toEqual('Hello world')
    expect(question.id).toBeFalsy()
    expect(question.answers.length).toBe(0)

  it 'should allow for multi-line body appending', ->
    builder = new @QuestionBuilder()
    builder.appendToBody('Hello\n\nworld')
    builder.appendToBody('Hiya')
    question = builder.build()
    expect(question.body).toEqual('Hello\n\nworld\n\nHiya')
    expect(question.id).toBeFalsy()
    expect(question.answers.length).toBe(0)

  it 'should create questions with identifiers', ->
    builder = new @QuestionBuilder()
    builder.appendToBody('Hello world')
    builder.setIdentifier('id')
    question = builder.build()
    expect(question.body).toEqual('Hello world')
    expect(question.id).toEqual('id')
    expect(question.answers.length).toBe(0)

  it 'should not allow setting identifier twice', ->
    builder = new @QuestionBuilder()
    builder.setIdentifier('id1')
    expect ->
      builder.setIdentifier('id2')
    .toThrow()

  it 'should allow for multiline questions', ->
    builder = new @QuestionBuilder()
    builder.appendToBody('Hello world')
    builder.appendToBody('How are you?')
    builder.appendToBody('Cool? Cool.')
    expect(builder.build().body).toEqual('Hello world\n\nHow are you?\n\nCool? Cool.')

  it 'should allow for body-only questions', ->
    builder = new @QuestionBuilder()
    builder.appendToBody('Hello world')
    question = builder.build()
    expect(question.body).toEqual('Hello world')
    expect(question.id).toBeFalsy()
    expect(question.answers).toBeArrayOfSize(0)

  it 'should allow for answer-only questions', ->
    builder = new @QuestionBuilder()
    builder.addAnswer('First answer', '>', 'a')
    question = builder.build()
    expect(question.body).toEqual('')
    expect(question.id).toBeFalsy()
    expect(question.answers.length).toBe(1)
    expect(question.answers[0].body).toEqual('First answer')
    expect(question.answers[0].correct).toBe(true)
    expect(question.answers[0].id).toEqual('a')

  it 'should allow for regular questions', ->
    builder = new @QuestionBuilder()
    builder.appendToBody('Hello world')
    builder.addAnswer('First answer', '>', 'a')
    builder.addAnswer('Second answer', false, 'b')
    question = builder.build()
    expect(question.body).toEqual('Hello world')
    expect(question.answers.length).toBe(2)
    expect(question.answers[0].body).toEqual('First answer')
    expect(question.answers[0].correct).toBe(true)
    expect(question.answers[0].id).toEqual('a')
    expect(question.answers[1].body).toEqual('Second answer')
    expect(question.answers[1].correct).toBe(false)
    expect(question.answers[1].id).toEqual('b')

  it 'should allow for no correct answers', ->
    builder = new @QuestionBuilder()
    builder.addAnswer('First answer', false, 'a')
    builder.addAnswer('Second answer', false, 'b')
    question = builder.build()
    expect(question.answers.length).toBe(2)
    expect(question.answers[0].body).toEqual('First answer')
    expect(question.answers[0].correct).toBe(false)
    expect(question.answers[0].id).toEqual('a')
    expect(question.answers[1].body).toEqual('Second answer')
    expect(question.answers[1].correct).toBe(false)
    expect(question.answers[1].id).toEqual('b')

  it 'should allow for duplicate identifiers', ->
    builder = new @QuestionBuilder()
    builder.addAnswer('First answer', false, 'a')
    builder.addAnswer('Second answer', '>', 'a')
    question = builder.build()
    expect(question.answers.length).toBe(2)
    expect(question.answers[0].body).toEqual('First answer')
    expect(question.answers[0].correct).toBe(false)
    expect(question.answers[0].id).toEqual('a')
    expect(question.answers[1].body).toEqual('Second answer')
    expect(question.answers[1].correct).toBe(true)
    expect(question.answers[1].id).toEqual('a')

  it 'should allow for multiline answers', ->
    builder = new @QuestionBuilder()
    builder.addAnswer('First line', '>>>', 'Z')
    builder.appendAnswerLine('Second line')
    question = builder.build()
    expect(question.answers.length).toBe(1)
    expect(question.answers[0].body).toEqual('First line\nSecond line')
    expect(question.answers[0].correct).toBe(true)
    expect(question.answers[0].id).toEqual('Z')

  it 'should allow for multiple multiline answers', ->
    builder = new @QuestionBuilder()
    builder.addAnswer('First line', '>>>', 'Z')
    builder.appendAnswerLine('Second line')
    builder.addAnswer('Line 2.1', false, 'Z')
    builder.appendAnswerLine('Line 2.2')
    question = builder.build()
    expect(question.answers.length).toBe(2)
    expect(question.answers[0].body).toEqual('First line\nSecond line')
    expect(question.answers[0].correct).toBe(true)
    expect(question.answers[0].id).toEqual('Z')
    expect(question.answers[1].body).toEqual('Line 2.1\nLine 2.2')
    expect(question.answers[1].correct).toBe(false)
    expect(question.answers[1].id).toEqual('Z')

  it 'should allow for adding multiple answers at once', ->
    builder = new @QuestionBuilder()
    builder.addAnswers [
      new @Answer('answer 1', yes, 'a')
      new @Answer('answer 2', no, 'b')
    ]
    question = builder.build()
    expect(question.answers).toEqualAnswers [
      new @Answer('answer 1', yes, 'a')
      new @Answer('answer 2', no, 'b')
    ]

  it 'should chain methods', ->
    new @QuestionBuilder()
    .appendToBody('body')
    .setIdentifier('id')
    .addAnswer('answer', true, 'X')
    .appendAnswerLine('line 2')
    .addAnswers([
      new @Answer('answer 1', yes, 'a')
      new @Answer('answer 2', no, 'b')
    ])
    .build()
    .body

  it 'should have independent instances', ->
    builder1 = new @QuestionBuilder()
    builder2 = new @QuestionBuilder()
    builder1.appendToBody('one')
    expect(builder1.build().body).toEqual('one')
    expect(builder2.build().body).toEqual('')
