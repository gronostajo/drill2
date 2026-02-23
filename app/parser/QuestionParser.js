angular.module('DrillApp').service('QuestionParser', function(Pipeline, ParsingUtils, QuestionParsingUtils, OptionsBlockUtils) {
  return new (class {
    parse(input) {
      var options, pipeline;
      options = {};
      pipeline = new Pipeline(input).apply(ParsingUtils.splitWithDoubleLines).filter(QuestionParsingUtils.matchNonEmptyStrings).apply(OptionsBlockUtils.loadOptions(options)).map(QuestionParsingUtils.parseQuestion).apply(QuestionParsingUtils.mergeBrokenQuestions).apply(QuestionParsingUtils.removeInvalidQuestions).apply(OptionsBlockUtils.assignQuestionExtras(options));
      return {
        questions: pipeline.get(),
        options: options,
        log: pipeline.getLog()
      };
    }

  })();
});
