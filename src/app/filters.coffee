angular.module 'DrillApp'

.filter 'decPlaces', ->
  (x, dec) ->
    pow = 10 ** dec
    (Math.round x * pow) / pow

.filter 'markdown', ($sce) ->
  (str, $scope) ->
    return '' unless str && $scope.config.markdown

    parser = new commonmark.Parser()
    renderer = new commonmark.HtmlRenderer()

    ast = parser.parse str

    # fixes double newlines
    fix = (node) ->
      if node._type is 'CodeBlock'
        # fix double newlines
        str = node._literal

        # fenced code blocks have additional newlines on ends
        if node._isFenced
          str = str.substring 1, (str.length - 1)

        split = str.split '\n'
        wanted = []

        for i in [0...split.length] by 2
          wanted.push split[i]

        node._literal = wanted.join '\n'
        return

      else
        fix node._firstChild if node._firstChild
        fix node._next if node._next
        return

    fix ast
    html = renderer.render ast

    $sce.trustAsHtml html

.filter 'lines', ->
  (str) ->
    if str then str.split /\s*(?:\r?\n)(?:\r?\n\s)*/ else []

.filter 'doubleNewlines', ->
  (str) ->
    if str then str.replace(/\n+/g, '\n\n') else ''

.filter 'minutes', ->
  (secs) ->
    return '' unless secs
    secs = parseInt secs

    mins = Math.floor (secs / 60)
    secs = (secs % 60).toString()
    while secs.length < 2
      secs = '0' + secs

    "#{mins}:#{secs}"

.filter 'minsSecs', ->
  (secs) ->
    mins = Math.floor (secs / 60)
    mstr = if mins > 0 then mins + 'm ' else ''
    mstr + (secs % 60) + 's'

.filter 'scoreFormat', (decPlacesFilter, minsSecsFilter) ->
  (score, limitedTime, timeLimit) ->
    score_ = decPlacesFilter score.score, 2
    total = decPlacesFilter score.total, 2
    str = "#{score_} / #{total} pts"

    if limitedTime
      str += ', ' + minsSecsFilter(timeLimit - score.timeLeft)

    str

.filter 'no', ->
  (x, capitalized) ->
    x ? if capitalized then 'No' else 'no'

.filter 'averageTime', ->
  (questions, timeLimit) ->
    count = 0
    total = 0
    for question in questions
      count += question.scoreLog.length
      for log in question.scoreLog
        total += timeLimit - log.timeLeft

    Math.round (total / count)

.filter 'shuffle', ->
  (input) ->
    arr = input[..]
    pivot = arr.length
    return arr if pivot <= 1

    while --pivot
      pick = Math.floor(Math.random() * (pivot + 1))
      [arr[pivot], arr[pick]] = [arr[pick], arr[pivot]]

    arr

.filter 'percentageOf', ->
  (fraction, total) ->
    if total != 0
      Math.round(fraction * 100 / total) + '%'
    else '0%'

.filter 'bankersPercentageOf', ->
  (fraction, total) ->
    if total != 0
      # adapted from http://stackoverflow.com/a/3109234/1937994
      num = fraction * 100 / total
      truncatedNum = num.toFixed(8)
      numFloor = Math.floor(truncatedNum)
      delta = truncatedNum - numFloor
      epsilon = 1e-8
      rounded = if delta > 0.5 - epsilon && delta < 0.5 + epsilon
        if numFloor % 2 == 0 then numFloor else numFloor + 1
      else
        Math.round(truncatedNum)
      rounded + '%'
    else '0%'
