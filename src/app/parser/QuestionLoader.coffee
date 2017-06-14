angular.module('DrillApp').service 'QuestionLoader', ($q, QuestionParser) ->
  new class
    loadFromString: (input) ->
      try
        {questions, options, log} = QuestionParser.parse(input)
        bankInfo =
          fileFormat: options.fileFormat
          explanationsAvailable: options.explanationsAvailable
          questionCount: questions.length
        $q.resolve {
          bankInfo: bankInfo
          config: options
          loadedQuestions: questions
          log: log
        }
      catch e
        $q.reject(e)
