describe 'QuestionParsingUtils.matchNonEmptyStrings', ->
  beforeEach ->
    module('DrillApp')
    inject (QuestionParsingUtils) ->
      @fn = QuestionParsingUtils.matchNonEmptyStrings

  it 'should reject empty strings', ->
    expect(@fn('')).toBe(false)
    expect(@fn(' ')).toBe(false)
    expect(@fn('\n')).toBe(false)
    expect(@fn('\r')).toBe(false)
    expect(@fn('\r\n')).toBe(false)
    expect(@fn('\t')).toBe(false)
    expect(@fn('\n\n')).toBe(false)
    expect(@fn('\n \n')).toBe(false)

  it 'should accept non-empty strings', ->
    expect(@fn('a')).toBe(true)
    expect(@fn('XYZ')).toBe(true)
    expect(@fn(' a ')).toBe(true)
    expect(@fn(' \t\n\nx\r\r  ')).toBe(true)
    expect(@fn('a     \r     z')).toBe(true)
