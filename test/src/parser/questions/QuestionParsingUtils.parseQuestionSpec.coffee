# coffeelint: disable=no_unnecessary_double_quotes
# because it doesn't work properly with block strings

describe 'QuestionParsingUtils.parseQuestion', ->
  beforeEach ->
    module('DrillApp')
    inject (QuestionParsingUtils) ->
      @fn = QuestionParsingUtils.parseQuestion

  it 'should parse simple question', ->
    result = @fn """
                 Hello world
                 > a) Hello Karma
                 b) Hello Sir William
                 """
    expect(result.body).toEqual('Hello world')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(2)
    expect(result.answers[0].body).toEqual('Hello Karma')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')
    expect(result.answers[1].body).toEqual('Hello Sir William')
    expect(result.answers[1].correct).toBe(false)
    expect(result.answers[1].id).toEqual('b')

  it 'should parse multi-line body', ->
    result = @fn """
                 Hello world
                 Hello darkness my old friend
                 > a) Hello Karma
                 b) Hello Sir William
                 """
    expect(result.body).toEqual('Hello world\n\nHello darkness my old friend')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(2)
    expect(result.answers[0].body).toEqual('Hello Karma')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')
    expect(result.answers[1].body).toEqual('Hello Sir William')
    expect(result.answers[1].correct).toBe(false)
    expect(result.answers[1].id).toEqual('b')

  it 'should parse question without body', ->
    result = @fn """
                 > a) Hello Karma
                 b) Hello Sir William
                 """
    expect(result.body).toEqual('')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(2)
    expect(result.answers[0].body).toEqual('Hello Karma')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')
    expect(result.answers[1].body).toEqual('Hello Sir William')
    expect(result.answers[1].correct).toBe(false)
    expect(result.answers[1].id).toEqual('b')

  it 'should parse question with identifier', ->
    result = @fn """
                 [#ok] Hello world
                 > a) Hello Karma
                 """
    expect(result.body).toEqual('Hello world')
    expect(result.id).toEqual('ok')
    expect(result.answers.length).toBe(1)
    expect(result.answers[0].body).toEqual('Hello Karma')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')

  it 'should parse multi-line question with identifier', ->
    result = @fn """
                 [#ok] Hello
                 world
                 > a) Hello Karma
                 """
    expect(result.body).toEqual('Hello\n\nworld')
    expect(result.id).toEqual('ok')
    expect(result.answers.length).toBe(1)
    expect(result.answers[0].body).toEqual('Hello Karma')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')

  it 'should not parse identifier in second line', ->
    result = @fn """
                 Hello world
                 [#1] Anybody there?
                 > a) Hello Karma
                 b) Hello Sir William
                 """
    expect(result.body).toEqual('Hello world\n\n[#1] Anybody there?')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(2)
    expect(result.answers[0].body).toEqual('Hello Karma')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')
    expect(result.answers[1].body).toEqual('Hello Sir William')
    expect(result.answers[1].correct).toBe(false)
    expect(result.answers[1].id).toEqual('b')

  it 'should parse question without correct answers', ->
    result = @fn """
                 Hello world
                 a) Hello Karma
                 b) Hello Sir William
                 """
    expect(result.body).toEqual('Hello world')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(2)
    expect(result.answers[0].body).toEqual('Hello Karma')
    expect(result.answers[0].correct).toBe(false)
    expect(result.answers[0].id).toEqual('a')
    expect(result.answers[1].body).toEqual('Hello Sir William')
    expect(result.answers[1].correct).toBe(false)
    expect(result.answers[1].id).toEqual('b')

  it 'should parse question with duplicate answer letters', ->
    result = @fn """
                 Hello world
                 > b) Hello Karma
                 b) Hello Sir William
                 """
    expect(result.body).toEqual('Hello world')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(2)
    expect(result.answers[0].body).toEqual('Hello Karma')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('b')
    expect(result.answers[1].body).toEqual('Hello Sir William')
    expect(result.answers[1].correct).toBe(false)
    expect(result.answers[1].id).toEqual('b')

  it 'should parse question without answers', ->
    result = @fn """
                 Hello world
                 """
    expect(result.body).toEqual('Hello world')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(0)

  it 'should parse multi-line answer', ->
    result = @fn """
                 Hello world
                 > a) Hello Karma
                 How are you today?
                 """
    expect(result.body).toEqual('Hello world')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(1)
    expect(result.answers[0].body).toEqual('Hello Karma\nHow are you today?')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')

  it 'should parse multi-line answer with indentation', ->
    result = @fn """
                 Hello world
                 > a) Hello Karma
                      How are you today?
                 """
    expect(result.body).toEqual('Hello world')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(1)
    expect(result.answers[0].body).toEqual('Hello Karma\nHow are you today?')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')

  it 'should parse multi-line answer followed by one-line answer', ->
    result = @fn """
                 Hello world
                 > a) Hello Karma
                 How are you today?
                 b) Hello Sir William
                 """
    expect(result.body).toEqual('Hello world')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(2)
    expect(result.answers[0].body).toEqual('Hello Karma\nHow are you today?')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')
    expect(result.answers[1].body).toEqual('Hello Sir William')
    expect(result.answers[1].correct).toBe(false)
    expect(result.answers[1].id).toEqual('b')

  it 'should parse two multi-line answers', ->
    result = @fn """
                 Hello world
                 > a) Hello Karma
                 How are you today?
                 b) Hello Sir William
                 Drop your panties Sir William
                 """
    expect(result.body).toEqual('Hello world')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(2)
    expect(result.answers[0].body).toEqual('Hello Karma\nHow are you today?')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')
    expect(result.answers[1].body).toEqual('Hello Sir William\nDrop your panties Sir William')
    expect(result.answers[1].correct).toBe(false)
    expect(result.answers[1].id).toEqual('b')

  it 'should work when called repeatedly', ->
    input = """
            Hello world
            > a) Hello Karma
            b) Hello Sir William
            """
    @fn(input)
    @fn(input)
    result = @fn(input)
    expect(result.body).toEqual('Hello world')
    expect(result.id).toBeFalsy()
    expect(result.answers.length).toBe(2)
    expect(result.answers[0].body).toEqual('Hello Karma')
    expect(result.answers[0].correct).toBe(true)
    expect(result.answers[0].id).toEqual('a')
    expect(result.answers[1].body).toEqual('Hello Sir William')
    expect(result.answers[1].correct).toBe(false)
    expect(result.answers[1].id).toEqual('b')

# coffeelint: enable=no_unnecessary_double_quotes
