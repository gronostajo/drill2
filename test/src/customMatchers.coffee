customMatchers =
  _toEqual: ->
    compare: (actual, expected) ->
      pass: _.isEqual(actual, expected)
