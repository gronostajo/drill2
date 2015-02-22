app = angular.module 'DrillApp'


app.factory 'GraderFactory', (SafeEvalService) ->

  createPerQuestionGrader: (max, radical = true) ->
    (question) ->
      ret =
        score: 0
        total: max

      correct = question.correct()
      incorrect = question.incorrect()

      unless radical and (incorrect or not correct)
        ret.score = Math.max (max * ((correct - incorrect) / question.totalCorrect())), 0
      ret

  createPerAnswerGrader: (radical = true) ->
    (question) ->
      ret =
        score: 0
        total: question.totalCorrect()

      correct = question.correct()
      incorrect = question.incorrect()

      unless radical and (incorrect or not correct)
        ret.score = Math.max (correct - incorrect), 0
      ret


  createOneLinerGrader: (oneliner) ->
    (question) ->
      questionInfo = (id) ->
        switch id
          when 'correct'
            question.correct()
          when 'incorrect'
            question.incorrect()
          when 'missed'
            question.missed()
          when 'total'
            question.totalCorrect()
          else
            0

      fakeInfo = (id) ->
        switch id
          when 'correct', 'total'
            question.totalCorrect()
          else
            0

      score: SafeEvalService.eval(oneliner, questionInfo)
      total: SafeEvalService.eval(oneliner, fakeInfo)