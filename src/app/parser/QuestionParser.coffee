angular.module('DrillApp').service 'QuestionParser',
  (Pipeline, ParsingUtils, QuestionParsingUtils, OptionsBlockUtils) ->
    new class
      parse: (input) ->
        options = {}

        pipeline = new Pipeline(input)
        .apply(ParsingUtils.splitWithDoubleLines)
        .filter(QuestionParsingUtils.matchNonEmptyStrings)

        .apply(OptionsBlockUtils.loadOptions(options))

        .map(QuestionParsingUtils.parseQuestion)
        .apply(QuestionParsingUtils.mergeBrokenQuestions)
        .apply(QuestionParsingUtils.removeInvalidQuestions)

        .apply(OptionsBlockUtils.assignQuestionExtras(options))

        questions: pipeline.get()
        options: options
        log: pipeline.getLog()
