angular.module('DrillApp').service('QuestionLoader', function($q, QuestionParser) {
  return new ((function() {
    function _Class() {}

    _Class.prototype.loadFromString = function(input) {
      var bankInfo, e, error, log, options, questions, ref;
      try {
        ref = QuestionParser.parse(input), questions = ref.questions, options = ref.options, log = ref.log;
        bankInfo = {
          fileFormat: options.fileFormat,
          explanationsAvailable: options.explanationsAvailable,
          questionCount: questions.length
        };
        return $q.resolve({
          bankInfo: bankInfo,
          config: options,
          loadedQuestions: questions,
          log: log
        });
      } catch (error) {
        e = error;
        return $q.reject(e);
      }
    };

    return _Class;

  })());
});
