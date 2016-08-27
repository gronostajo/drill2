describe 'ParsingUtils.splitWithNewlines', ->
  beforeEach ->
    module('DrillApp')
    inject (@ParsingUtils) ->

  it 'should split CRLF string', ->
    input = 'qwe\r\nasd\r\nzxc'
    expect(@ParsingUtils.splitWithNewlines(input)).toEqual(['qwe', 'asd', 'zxc'])

  it 'should split LF string', ->
    input = 'qwe\nasd\nzxc'
    expect(@ParsingUtils.splitWithNewlines(input)).toEqual(['qwe', 'asd', 'zxc'])

  it 'should split mixed string', ->
    input = 'qwe\r\nasd\nzxc'
    expect(@ParsingUtils.splitWithNewlines(input)).toEqual(['qwe', 'asd', 'zxc'])


describe 'ParsingUtils.splitWithDoubleLines', ->
  beforeEach ->
    module('DrillApp')
    inject (@ParsingUtils) ->

  it 'should split CRLF file', ->
    input = 'qwe\r\n\r\nasd\r\n\r\nzxc'
    expect(@ParsingUtils.splitWithDoubleLines(input)).toEqual(['qwe', 'asd', 'zxc'])

  it 'should split LF file', ->
    input = 'qwe\n\nasd\n\nzxc'
    expect(@ParsingUtils.splitWithDoubleLines(input)).toEqual(['qwe', 'asd', 'zxc'])

  it 'should split mixed file', ->
    input = 'qwe\r\n\nasd\n\r\nzxc'
    expect(@ParsingUtils.splitWithDoubleLines(input)).toEqual(['qwe', 'asd', 'zxc'])

  it 'should split on more than two newlines', ->
    input = 'qwe\n\n\nasd\n\nzxc'
    expect(@ParsingUtils.splitWithDoubleLines(input)).toEqual(['qwe', 'asd', 'zxc'])


describe 'ParsingUtils.matchAnswer', ->
  beforeEach ->
    module('DrillApp')
    inject (@ParsingUtils) ->
      @fn = @ParsingUtils.matchAnswer

  it 'should match answer with single answer mark', ->
    result = @fn('> a) test')
    expect(result).toBeTruthy()
    expect(result.correct).toEqual('>')

  it 'should match answer with multiple answer marks', ->
    result = @fn('>> a) test')
    expect(result).toBeTruthy()
    expect(result.correct).toEqual('>>')
    result = @fn('>>> a) test')
    expect(result).toBeTruthy()
    expect(result.correct).toEqual('>>>')

  it 'should parse letters correctly', ->
    result = @fn('> a) test')
    expect(result).toBeTruthy()
    expect(result.letter).toEqual('a')
    result = @fn('> b) test')
    expect(result).toBeTruthy()
    expect(result.letter).toEqual('b')
    result = @fn('> z) test')
    expect(result).toBeTruthy()
    expect(result.letter).toEqual('z')

  it 'should accept uppercase and lowercase answer letters', ->
    result = @fn('> a) test')
    expect(result).toBeTruthy()
    expect(result.letter).toEqual('a')
    result = @fn('> A) test')
    expect(result).toBeTruthy()
    expect(result.letter).toEqual('A')
    result = @fn('> Z) test')
    expect(result).toBeTruthy()
    expect(result.letter).toEqual('Z')

  it 'should allow for whitespace before correct answer', ->
    result = @fn(' \t > a) test')
    expect(result).toBeTruthy()
    expect(result.correct).toBeTruthy()
    expect(result.letter).toEqual('a')

  it 'should allow for whitespace before incorrect answer', ->
    result = @fn(' \t a) test')
    expect(result).toBeTruthy()
    expect(result.correct).toBeFalsy()
    expect(result.letter).toEqual('a')

  it 'should allow for whitespace between correct answer mark and letter', ->
    result = @fn('>\t a) test')
    expect(result).toBeTruthy()
    expect(result.correct).toBeTruthy()
    expect(result.letter).toEqual('a')

  it 'should allow for no whitespace between correct answer mark and letter', ->
    result = @fn('>a) test')
    expect(result).toBeTruthy()
    expect(result.correct).toBeTruthy()
    expect(result.letter).toEqual('a')

  it 'should allow for whitespace between parenthesis and content', ->
    result = @fn('a)   \t \t  te st_\nfj')
    expect(result).toBeTruthy()
    expect(result.content).toEqual('te st_\nfj')

  it 'should allow for no whitespace between parenthesis and content', ->
    result = @fn('a)te st_\nfj')
    expect(result).toBeTruthy()
    expect(result.content).toEqual('te st_\nfj')

  it 'should reject identifiers other than letters', ->
    expect(@fn('2) content')).toBe(false)
    expect(@fn('#) content')).toBe(false)
    expect(@fn('_) content')).toBe(false)
    expect(@fn('-) content')).toBe(false)
    expect(@fn(') content')).toBe(false)

  it 'should require identifier', ->
    expect(@fn('content')).toBe(false)
    expect(@fn('\t content')).toBe(false)
    expect(@fn('> content')).toBe(false)
    expect(@fn('>content')).toBe(false)


describe 'ParsingUtils.matchIdentifier', ->
  beforeEach ->
    module('DrillApp')
    inject (@ParsingUtils) ->
      @fn = @ParsingUtils.matchIdentifier

  it 'should capture identifier', ->
    result = @fn('[#1] content')
    expect(result).toBeTruthy()
    expect(result.identifier).toEqual('1')

  it 'should capture content', ->
    result = @fn('[#1] content \n test _! $%* ./')
    expect(result).toBeTruthy()
    expect(result.content).toEqual('content \n test _! $%* ./')

  it 'should allow letters, numbers, _ - and + in identifier', ->
    result = @fn('[#+1a_-] content')
    expect(result).toBeTruthy()
    expect(result.identifier).toEqual('+1a_-')

  it 'should not allow weird characters in identifier', ->
    result = @fn('[#$] content')
    expect(result).toBe(false)

  it 'should return false for no identifier', ->
    result = @fn('content')
    expect(result).toBe(false)

  it 'should not allow for whitespace before identifier', ->
    expect(@fn(' [#1] content')).toBe(false)

  it 'should allow empty content', ->
    result = @fn('[#1] \t ')
    expect(result).toBeTruthy()
    expect(result.content).toEqual('')
