angular.module('DrillApp').service 'LegacyParser', (Pipeline, ParsingUtils, QuestionParsingUtils) ->
  new class
    canHandle: -> yes

    parse: (input) ->
      pipeline = new Pipeline(input)
      .apply(ParsingUtils.splitWithDoubleLines)
      .filter(QuestionParsingUtils.matchNonEmptyStrings)
      .map(QuestionParsingUtils.parseQuestion)
      .apply(QuestionParsingUtils.mergeBrokenQuestions)
      .apply(QuestionParsingUtils.removeInvalidQuestions)

      questions: pipeline.get()
      log: pipeline.getLog()
