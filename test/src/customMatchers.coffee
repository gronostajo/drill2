customMatchers =
  toEqualQuestion: ->
    compare: (actual, expected) ->
      detailsMatch = customMatchers.toEqualQuestionDetails().compare(actual, expected)
      if not detailsMatch.pass
        detailsMatch
      else return customMatchers.toEqualAnswers().compare(actual.answers, expected.answers)

  toEqualQuestionDetails: ->
    compare: (actual, expected) ->
      if actual.body isnt expected.body
        pass: no
        message: "Question body '#{actual.body}' is not '#{expected.body}'"
      else if actual.id isnt expected.id
        pass: no
        message: "Question id '#{actual.id}' is not '#{expected.id}'"
      else
        pass: yes

  toEqualAnswers: ->
    compare: (actual, expected) ->
      if actual.length isnt expected.length
        return {
          pass: no
          message: "Answer count #{actual.length} is not #{expected.length}"
        }

      for index in [0...actual.length]
        actualAnswer = actual[index]
        expectedAnswer = expected[index]
        answersMatch = customMatchers.toEqualAnswer(index).compare(actualAnswer, expectedAnswer)
        if not answersMatch.pass
          return answersMatch

      return pass: yes

  toEqualAnswer: (index) ->
    compare: (actual, expected) ->
      name = if index then "Answer ##{index + 1}" else 'Answer'
      if actual.body isnt expected.body
        pass: no
        message: "#{name} body '#{actual.body}' is not '#{expected.body}'"
      else if actual.id isnt expected.id
        pass: no
        message: "#{name} id '#{actual.id}' is not '#{expected.id}'"
      else if actual.correct isnt expected.correct
        pass: no
        message: "#{name} correctness '#{actual.correct}' is not '#{expected.correct}'"
      else
        pass: yes
