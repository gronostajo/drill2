angular.module('DrillApp').service('QuestionLoader', function($q, QuestionParser) {
  return new (class {
    loadFromString(input) {
      var bankInfo, e, log, options, questions;
      try {
        ({questions, options, log} = QuestionParser.parse(input));
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
    }

  })();
});
