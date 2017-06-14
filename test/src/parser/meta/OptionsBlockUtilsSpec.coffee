describe 'OptionsBlockProcessor', ->
  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (@OptionsBlockUtils, @Question) ->

  describe 'loadOptions', ->
    it 'should not change anything if options block is missing', ->
      logger = jasmine.createSpy('logger')
      input = [
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
      ]
      output = @OptionsBlockUtils.loadOptions({})(input, logger)
      expect(output).toBeArrayOfSize(3)
      for item in output
        expect(item).toEqual('Question\n> a) correct\nb> incorrect')
      expect(logger).not.toHaveBeenCalled()

    it 'should recognize options block and remove it', ->
      logger = jasmine.createSpy('logger')
      input = [
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        '<options> {"format": "legacy"}'
      ]
      output = @OptionsBlockUtils.loadOptions({})(input, logger)
      expect(output).toBeArrayOfSize(3)
      for item in output
        expect(item).toEqual('Question\n> a) correct\nb> incorrect')
      expect(logger).not.toHaveBeenCalled()

    it 'should allow whitespace around options block', ->
      logger = jasmine.createSpy('logger')
      input = [
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        ' \t <options>   {"format": "legacy"} \t'
      ]
      output = @OptionsBlockUtils.loadOptions({})(input, logger)
      expect(output).toBeArrayOfSize(3)
      for item in output
        expect(item).toEqual('Question\n> a) correct\nb> incorrect')
      expect(logger).not.toHaveBeenCalled()

    it 'should not modify input data', ->
      input = [
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        '<options> {"format": "legacy"}'
      ]
      @OptionsBlockUtils.loadOptions({})(input)
      expect(input).toBeArrayOfSize(4)
      expect(input[0]).toEqual('Question\n> a) correct\nb> incorrect')
      expect(input[1]).toEqual('Question\n> a) correct\nb> incorrect')
      expect(input[2]).toEqual('Question\n> a) correct\nb> incorrect')
      expect(input[3]).toEqual('<options> {"format": "legacy"}')

    it 'should handle empty input gracefully', ->
      logger = jasmine.createSpy('logger')
      expect =>
        @OptionsBlockUtils.loadOptions({})([], logger)
      .not.toThrow()
      expect(logger).not.toHaveBeenCalled()

    it 'should throw for invalid values', ->
      validInput = [
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        '<options> {"format": "legacy"}'
      ]
      expect(-> @OptionsBlockUtils.loadOptions({})({})).toThrow()
      expect(-> @OptionsBlockUtils.loadOptions({})('')).toThrow()
      expect(-> @OptionsBlockUtils.loadOptions({})(false)).toThrow()
      expect(-> @OptionsBlockUtils.loadOptions([])(validInput)).toThrow()
      expect(-> @OptionsBlockUtils.loadOptions('')(validInput)).toThrow()
      expect(-> @OptionsBlockUtils.loadOptions(false)(validInput)).toThrow()

    it 'should work if nothing but options block is present', ->
      logger = jasmine.createSpy('logger')
      target = {}
      input = [
        '<options> {"format": "legacy"}'
      ]
      output = @OptionsBlockUtils.loadOptions(target)(input, logger)
      expect(output).toBeEmptyArray()
      expect(target).toBeNonEmptyObject()
      expect(logger).not.toHaveBeenCalled()

    it 'should work if not only options block is present', ->
      logger = jasmine.createSpy('logger')
      target = {}
      input = [
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        'Question\n> a) correct\nb> incorrect'
        '<options> {"format": "legacy"}'
      ]
      @OptionsBlockUtils.loadOptions(target)(input, logger)
      expect(target).toBeNonEmptyObject()
      expect(logger).not.toHaveBeenCalled()

    it 'should read options', ->
      target = {}
      input = [
        'Question\n> a) correct\nb> incorrect'
        '<options> {"format": "2"}'
      ]
      @OptionsBlockUtils.loadOptions(target)(input)
      expect(target.format).toEqual('2')

    it 'should fail gracefully when options syntax is incorrect', ->
      input = [
        'Question\n> a) correct\nb> incorrect'
        '<options> {"format": invalid,}'
      ]
      target = {}
      expect =>
        @OptionsBlockUtils.loadOptions(target)(input)
      .not.toThrow()
      expect(target.format).toEqual('legacy')

    it 'should log invalid values', ->
      target = {}
      logger = jasmine.createSpy('logger')
      input = [
        'Question\n> a) correct\nb> incorrect'
        '<options> {"grading": "somethingWeird"}'
      ]
      @OptionsBlockUtils.loadOptions(target)(input, logger)
      expect(target.gradingMethod).toEqual('perAnswer')
      expect(logger).toHaveBeenCalledTimes(1)

    it 'should always extract explanations', ->
      target = {}
      input = [
        'Question\n> a) correct\nb> incorrect'
        '<options> {}'
      ]
      @OptionsBlockUtils.loadOptions(target)(input)
      expect(target.explanations).toBeObject()

  describe 'assignQuestionExtras', ->
    it 'should throw on invalid input', ->
      expect(-> @OptionsBlockUtils.assignQuestionExtras({explanations: {}, relatedLinks: {}})({})).toThrow()
      expect(-> @OptionsBlockUtils.assignQuestionExtras({explanations: {}, relatedLinks: {}})('')).toThrow()
      expect(-> @OptionsBlockUtils.assignQuestionExtras({explanations: {}, relatedLinks: {}})(false)).toThrow()
      expect(-> @OptionsBlockUtils.assignQuestionExtras({explanations: {}})([])).toThrow()
      expect(-> @OptionsBlockUtils.assignQuestionExtras({relatedLinks: {}})([])).toThrow()
      expect(-> @OptionsBlockUtils.assignQuestionExtras([])([])).toThrow()
      expect(-> @OptionsBlockUtils.assignQuestionExtras('')([])).toThrow()
      expect(-> @OptionsBlockUtils.assignQuestionExtras(false)([])).toThrow()
      expect(-> @OptionsBlockUtils.assignQuestionExtras({})([])).toThrow()

    it 'should handle empty input', ->
      logger = jasmine.createSpy('logger')
      expect =>
        @OptionsBlockUtils.assignQuestionExtras({explanations: {}, relatedLinks: {}})([], logger)
      .not.toThrow()
      expect(logger).not.toHaveBeenCalled()

    it 'should assign present explanations', ->
      logger = jasmine.createSpy('logger')
      questions = [
        new @Question('Body 1', '1')
        new @Question('Body 2', '2')
      ]
      explanations = {
        '1': 'Explanation 1'
        '2': 'Explanation 2'
      }
      output = @OptionsBlockUtils.assignQuestionExtras({explanations, relatedLinks: {}})(questions, logger)
      expect(output[0].explanation).toEqual('Explanation 1')
      expect(output[0].hasExplanations).toBe(true)
      expect(output[1].explanation).toEqual('Explanation 2')
      expect(output[1].hasExplanations).toBe(true)
      expect(logger).not.toHaveBeenCalled()

    it 'should assign present related links', ->
      logger = jasmine.createSpy('logger')
      questions = [
        new @Question('Body 1', '1')
        new @Question('Body 2', '2')
      ]
      relatedLinks = {
        '1': ['link']
        '2': ['also link']
      }
      output = @OptionsBlockUtils.assignQuestionExtras({explanations: {}, relatedLinks})(questions, logger)
      expect(output[0].relatedLinks).toEqual(['link'])
      expect(output[1].relatedLinks).toEqual(['also link'])
      expect(logger).not.toHaveBeenCalled()

    it 'should assign only present explanations', ->
      logger = jasmine.createSpy('logger')
      questions = [
        new @Question('Body 1', '1')
        new @Question('Body 2', '2')
      ]
      explanations = {
        '1': 'Explanation 1'
      }
      output = @OptionsBlockUtils.assignQuestionExtras({explanations, relatedLinks: {}})(questions, logger)
      expect(output[0].explanation).toEqual('Explanation 1')
      expect(output[0].hasExplanations).toBe(true)
      expect(output[1].explanation).toBeFalsy()
      expect(output[1].hasExplanations).toBeFalsy()
      expect(logger).not.toHaveBeenCalled()

    it 'should assign only present related links', ->
      logger = jasmine.createSpy('logger')
      questions = [
        new @Question('Body 1', '1')
        new @Question('Body 2', '2')
      ]
      relatedLinks = {
        '1': ['link']
      }
      output = @OptionsBlockUtils.assignQuestionExtras({explanations: {}, relatedLinks})(questions, logger)
      expect(output[0].relatedLinks).toEqual(['link'])
      expect(output[1].relatedLinks).toEqual([])
      expect(logger).not.toHaveBeenCalled()

    it 'should work with questions without id', ->
      logger = jasmine.createSpy('logger')
      questions = [
        new @Question('Body 2', '2')
        new @Question('Body without ID')
      ]
      explanations = {
        '2': 'Explanation 2'
      }
      relatedLinks = {
        '2': ['link', 'link2']
      }
      @OptionsBlockUtils.assignQuestionExtras({explanations, relatedLinks})(questions, logger)
      expect(logger).not.toHaveBeenCalled()

    it 'should report unmatched explanations', ->
      logger = jasmine.createSpy('logger')
      questions = [
        new @Question('Body 2', '2')
        new @Question('Body 3', '3')
      ]
      explanations = {
        '0': 'Explanation 1'
        '2': 'Explanation 2'
      }
      output = @OptionsBlockUtils.assignQuestionExtras({explanations, relatedLinks: {}})(questions, logger)
      expect(output[0].explanation).toEqual('Explanation 2')
      expect(output[0].hasExplanations).toBe(true)
      expect(logger).toHaveBeenCalled()

    it 'should report unmatched related links', ->
      logger = jasmine.createSpy('logger')
      questions = [
        new @Question('Body 2', '2')
        new @Question('Body 3', '3')
      ]
      relatedLinks = {
        '0': ['link']
        '2': ['also link']
      }
      output = @OptionsBlockUtils.assignQuestionExtras({explanations: {}, relatedLinks})(questions, logger)
      expect(output[0].relatedLinks).toEqual(['also link'])
      expect(logger).toHaveBeenCalled()

    it 'should indicate that explanations were added', ->
      questions = [
        new @Question('Body 2', '2')
      ]
      options =
        explanations:
          '0': 'Explanation 1'
          '2': 'Explanation 2'
        relatedLinks: {}
      @OptionsBlockUtils.assignQuestionExtras(options)(questions, ->)
      expect(options.explanationsAvailable).toBe(true)

    it 'should not indicate that explanations were added if none were matched', ->
      questions = [
        new @Question('Body 2', '2')
      ]
      options =
        explanations:
          '0': 'Explanation 1'
          '3': 'Explanation 3'
        relatedLinks: {}
      @OptionsBlockUtils.assignQuestionExtras(options)(questions, ->)
      expect(options.explanationsAvailable).toBe(false)
