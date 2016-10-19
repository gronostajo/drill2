describe 'OptionsBlockProcessor', ->
  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (@OptionsBlockProcessor) ->

  defaults =
    format: 'legacy'
    markdownReady: no
    markdown: no
    mathjaxReady: no
    mathjax: no
    gradingMethod: 'perAnswer'
    gradingRadical: '0'
    gradingPPQ: 1
    timeLimitEnabled: no
    timeLimitSecs: 60
    repeatIncorrect: no
    explain: 'optional'
    showExplanations: no
    explanations: {}

  it 'should have correct defaults', ->
    logger = jasmine.createSpy('logger')
    expect(@OptionsBlockProcessor.process('{}', logger)).toEqualObject(defaults)
    expect(logger).not.toHaveBeenCalled()

  it 'should recognize formats', ->
    logger = jasmine.createSpy('logger')
    expect(@OptionsBlockProcessor.process('{"format": "legacy"}', logger)).toHaveMemberValues(format: 'legacy')
    expect(@OptionsBlockProcessor.process('{"format": "2"}', logger)).toHaveMemberValues(format: '2')
    expect(@OptionsBlockProcessor.process('{"format": "2.1"}', logger)).toHaveMemberValues(format: '2.1')
    expect(@OptionsBlockProcessor.process('{"format": "2.2"}', logger)).toHaveMemberValues(format: 'unknown')
    expect(@OptionsBlockProcessor.process('{"format": "whatever"}', logger)).toHaveMemberValues(format: 'unknown')
    expect(logger).not.toHaveBeenCalled()

  it 'should recognize markdown', ->
    expectedTrue =
      markdownReady: yes
      markdown: yes
    expectedFalse =
      markdownReady: no
      markdown: no
    logger = jasmine.createSpy('logger')

    expect(@OptionsBlockProcessor.process('{"markdown": true}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"markdown": "true"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"markdown": "enabled"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"markdown": "enable"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"markdown": "yes"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"markdown": "1"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"markdown": 1}', logger)).toHaveMemberValues(expectedTrue)

    expect(@OptionsBlockProcessor.process('{"markdown": false}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"markdown": "false"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"markdown": "disabled"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"markdown": "disable"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"markdown": "no"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"markdown": "0"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"markdown": 0}', logger)).toHaveMemberValues(expectedFalse)

    expect(logger).not.toHaveBeenCalled()

  it 'should recognize mathjax', ->
    expectedTrue =
      mathjaxReady: yes
      mathjax: yes
    expectedFalse =
      mathjaxReady: no
      mathjax: no
    logger = jasmine.createSpy('logger')

    expect(@OptionsBlockProcessor.process('{"mathjax": true}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"mathjax": "true"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"mathjax": "enabled"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"mathjax": "yes"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"mathjax": "1"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"mathjax": 1}', logger)).toHaveMemberValues(expectedTrue)

    expect(@OptionsBlockProcessor.process('{"mathjax": false}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"mathjax": "false"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"mathjax": "disabled"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"mathjax": "no"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"mathjax": "0"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"mathjax": 0}', logger)).toHaveMemberValues(expectedFalse)

    expect(logger).not.toHaveBeenCalled()

  it 'should recognize graders', ->
    logger = jasmine.createSpy('logger')
    customGrader = 'custom: incorrect ? 0 : (missed == 0) ? 3 : (missed == 1 && correct) ? 1 : 0'
    expect(@OptionsBlockProcessor.process('{"grading": "perQuestion"}', logger)).toHaveMemberValues
      gradingMethod: 'perQuestion'
    expect(@OptionsBlockProcessor.process('{"grading": "perAnswer"}', logger)).toHaveMemberValues
      gradingMethod: 'perAnswer'
    expect(@OptionsBlockProcessor.process('{"grading": "' + customGrader + '"}', logger)).toHaveMemberValues
      gradingMethod: 'custom'
      customGrader: 'incorrect ? 0 : (missed == 0) ? 3 : (missed == 1 && correct) ? 1 : 0'
    expect(logger).not.toHaveBeenCalled()

  it 'should log custom grader errors and fall back', ->
    logger = jasmine.createSpy('logger')
    customGrader = 'custom: inkorrekt ? 0 : (missed == 0) ? 3 : (missed == 1 && korrekt) ? 1 : 0'
    result = @OptionsBlockProcessor.process('{"grading": "' + customGrader + '"}', logger)
    expect(result.gradingMethod).toEqual('perAnswer')
    expect(result).not.toHaveMember('customGrader')
    expect(logger).toHaveBeenCalled()

  it 'should recognize radical grading param', ->
    expectedTrue = gradingRadical: '1'
    expectedFalse = gradingRadical: '0'
    logger = jasmine.createSpy('logger')

    expect(@OptionsBlockProcessor.process('{"gradingRadical": true}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": "true"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": "enabled"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": "yes"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": "1"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": 1}', logger)).toHaveMemberValues(expectedTrue)

    expect(@OptionsBlockProcessor.process('{"gradingRadical": false}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": "false"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": "disabled"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": "no"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": "0"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"gradingRadical": 0}', logger)).toHaveMemberValues(expectedFalse)

    expect(logger).not.toHaveBeenCalled()

  it 'should recognize grading PPQ param', ->
    logger = jasmine.createSpy('logger')

    expect(@OptionsBlockProcessor.process('{"gradingPPQ": "1"}', logger)).toHaveMemberValues(gradingPPQ: 1)
    expect(@OptionsBlockProcessor.process('{"gradingPPQ": 1}', logger)).toHaveMemberValues(gradingPPQ: 1)
    expect(@OptionsBlockProcessor.process('{"gradingPPQ": "3"}', logger)).toHaveMemberValues(gradingPPQ: 3)
    expect(@OptionsBlockProcessor.process('{"gradingPPQ": 3}', logger)).toHaveMemberValues(gradingPPQ: 3)
    expect(@OptionsBlockProcessor.process('{"gradingPPQ": "0"}', logger)).toHaveMemberValues(gradingPPQ: 1)
    expect(@OptionsBlockProcessor.process('{"gradingPPQ": 0}', logger)).toHaveMemberValues(gradingPPQ: 1)

    expect(logger).not.toHaveBeenCalled()

  it 'should recognize time limits', ->
    expectedFalse =
      timeLimitEnabled: no
      timeLimitSecs: 60
    expected30 =
      timeLimitEnabled: yes
      timeLimitSecs: 30
    logger = jasmine.createSpy('logger')

    expect(@OptionsBlockProcessor.process('{"timeLimit": 30}', logger)).toHaveMemberValues(expected30)
    expect(@OptionsBlockProcessor.process('{"timeLimit": "30"}', logger)).toHaveMemberValues(expected30)

    expect(@OptionsBlockProcessor.process('{"timeLimit": false}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"timeLimit": "false"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"timeLimit": "disabled"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"timeLimit": "no"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"timeLimit": "0"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"timeLimit": 0}', logger)).toHaveMemberValues(expectedFalse)

    expect(logger).not.toHaveBeenCalled()

  it 'should recognize repetition of incorrect questions', ->
    expectedTrue = repeatIncorrect: yes
    expectedFalse = repeatIncorrect: no
    logger = jasmine.createSpy('logger')

    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": true}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": "true"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": "enabled"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": "yes"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": "1"}', logger)).toHaveMemberValues(expectedTrue)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": 1}', logger)).toHaveMemberValues(expectedTrue)

    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": false}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": "false"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": "disabled"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": "no"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": "0"}', logger)).toHaveMemberValues(expectedFalse)
    expect(@OptionsBlockProcessor.process('{"repeatIncorrect": 0}', logger)).toHaveMemberValues(expectedFalse)

    expect(logger).not.toHaveBeenCalled()

  it 'should recognize explanation options', ->
    logger = jasmine.createSpy('logger')

    expect(@OptionsBlockProcessor.process('{"explain": "summary"}', logger)).toHaveMemberValues
      explain: 'summary'
      showExplanations: no
    expect(@OptionsBlockProcessor.process('{"explain": "optional"}', logger)).toHaveMemberValues
      explain: 'optional'
      showExplanations: no
    expect(@OptionsBlockProcessor.process('{"explain": "always"}', logger)).toHaveMemberValues
      explain: 'always'
      showExplanations: yes
    expect(logger).not.toHaveBeenCalled()

    expect(@OptionsBlockProcessor.process('{"explain": "whatever"}', logger)).toHaveMemberValues
      explain: 'optional'
      showExplanations: no
    expect(logger).toHaveBeenCalled()

  it 'should load explanations', ->
# coffeelint: disable=no_unnecessary_double_quotes
# because it doesn't work properly with block strings
    input = """
            { "explanations": {
              "1": "test",
              "A_+-Z": "test2"
            } }
            """
# coffeelint: enable=no_unnecessary_double_quotes
    logger = jasmine.createSpy('logger')
    result = @OptionsBlockProcessor.process(input, logger)
    expect(result.explanations).toEqualObject
      '1': 'test'
      'A_+-Z': 'test2'
    expect(logger).not.toHaveBeenCalled()

  it 'should reject invalid explanations', ->
# coffeelint: disable=no_unnecessary_double_quotes
# because it doesn't work properly with block strings
    input = """
            { "explanations": {
              "1": "test",
              "A_+-Z": "test2",
              "^regex-like$": "this is invalid"
            } }
            """
    # coffeelint: enable=no_unnecessary_double_quotes
    logger = jasmine.createSpy('logger').and.callFake (msg) ->
      expect(msg.toLowerCase()).toContainSubstring('invalid')
    result = @OptionsBlockProcessor.process(input, logger)
    expect(result.explanations).toEqualObject
      '1': 'test'
      'A_+-Z': 'test2'
    expect(logger).toHaveBeenCalled()

  it 'should reject empty explanations', ->
# coffeelint: disable=no_unnecessary_double_quotes
# because it doesn't work properly with block strings
    input = """
            { "explanations": {
              "1": "test",
              "A_+-Z": "test2",
              "valid_id": "",
              "valid_id2": "   "
            } }
            """
    # coffeelint: enable=no_unnecessary_double_quotes
    logger = jasmine.createSpy('logger').and.callFake (msg) ->
      expect(msg.toLowerCase()).toContainSubstring('empty')
    result = @OptionsBlockProcessor.process(input, logger)
    expect(result.explanations).toEqualObject
      '1': 'test'
      'A_+-Z': 'test2'
    expect(logger).toHaveBeenCalledTimes(2)

  it 'should reject non-string explanations', ->
# coffeelint: disable=no_unnecessary_double_quotes
# because it doesn't work properly with block strings
    input = """
            { "explanations": {
              "1": "test",
              "A_+-Z": "test2",
              "valid_id": 5
            } }
            """
    # coffeelint: enable=no_unnecessary_double_quotes
    logger = jasmine.createSpy('logger').and.callFake (msg) ->
      expect(msg.toLowerCase()).toContainSubstring('string')
    result = @OptionsBlockProcessor.process(input, logger)
    expect(result.explanations).toEqualObject
      '1': 'test'
      'A_+-Z': 'test2'
    expect(logger).toHaveBeenCalled()

  it 'should reject invalid explanation object', ->
    logger = jasmine.createSpy('logger')
    expect(@OptionsBlockProcessor.process('{"explanations": []}', logger))
    expect(@OptionsBlockProcessor.process('{"explanations": 5}', logger))
    expect(@OptionsBlockProcessor.process('{"explanations": false}', logger))
    expect(@OptionsBlockProcessor.process('{"explanations": "a lot of them"}', logger))
    expect(logger).toHaveBeenCalledTimes(4)

  it 'should log JSON syntax problem and return defaults', ->
    logger = jasmine.createSpy('logger').and.callFake (msg) ->
      expect(msg.toLowerCase()).toContainSubstring('syntax')
    expect(@OptionsBlockProcessor.process('{"format": "42",}', logger)).toEqualObject(defaults)
    expect(logger).toHaveBeenCalledTimes(1)
