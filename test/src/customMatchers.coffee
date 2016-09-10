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

  toHaveAllPropertiesOfObjectEqual: ->
    compare: (actual, expected) ->
      for member of expected when actual[member] isnt expected[member]
        return {
          pass: no
          message: "Mismatch for property #{member}: '#{actual[member]}' doesn't equal '#{expected[member]}'"
        }
      pass: yes

  toEqualObject: ->
    compare: (actual, expected) ->
      if not angular.isObject(actual)
        return {
          pass: no
          message: "#{actual} is not an object"
        }
      for member, actualValue of actual
        if (member of expected)
          expectedValue = expected[member]
          areObjects = angular.isObject(actualValue) and angular.isObject(expectedValue)
          areDifferentObjects = areObjects and not customMatchers.toEqualObject().compare(actualValue, expectedValue)
          if areDifferentObjects or (not areObjects and (actualValue isnt expectedValue))
            return {
              pass: no
              message: "Mismatch for property #{member}: #{actualValue} doesn't equal #{expectedValue}"
            }
        else if not (member of expected)
          return {
            pass: no
            message: "Unexpected property #{member}"
          }
      for member of expected when not (member of actual)
        return {
          pass: no
          message: "Missing property #{member}"
        }
      pass: yes

  toHaveMemberValues: ->
    compare: (actual, expected) ->
      if not angular.isObject(actual)
        return {
          pass: no
          message: "#{actual} is not an object"
        }
      for member, expectedValue of expected
        if not (member of actual)
          return {
            pass: no
            message: "Missing property #{member}"
          }
        else if actual[member] isnt expectedValue
          return {
            pass: no
            message: "Mismatch for property #{member}: #{actual[member]} doesn't equal #{expectedValue}"
          }
      pass: yes

  toContainSubstring: ->
    compare: (value, substring) ->
      if not angular.isString(value)
        pass: no
      else
        pass: value.indexOf(substring) > -1
