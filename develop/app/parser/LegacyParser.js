angular.module('DrillApp').service('LegacyParser', function(Pipeline, ParsingUtils, QuestionParsingUtils) {
  return new ((function() {
    function _Class() {}

    _Class.prototype.canHandle = function() {
      return true;
    };

    _Class.prototype.parse = function(input) {
      var pipeline;
      pipeline = new Pipeline(input).apply(ParsingUtils.splitWithDoubleLines).filter(QuestionParsingUtils.matchNonEmptyStrings).map(QuestionParsingUtils.parseQuestion).apply(QuestionParsingUtils.mergeBrokenQuestions).apply(QuestionParsingUtils.removeInvalidQuestions);
      return {
        questions: pipeline.get(),
        log: pipeline.getLog()
      };
    };

    return _Class;

  })());
});
