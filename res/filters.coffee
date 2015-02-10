drillApp = angular.module 'DrillApp'


drillApp.filter 'decPlaces', ->
  (x, dec) ->
    pow = 10 ** dec
    (Math.round x * pow) / pow


drillApp.filter 'markdown', ['$sce', ($sce) ->
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
]


drillApp.filter 'lines', ->
  (str) ->
    if str then str.split /\s*(?:\r?\n)(?:\r?\n\s)*/ else []


drillApp.filter 'doubleNewlines', ->
  (str) ->
    if str then str.replace(/\n+/g, '\n\n') else ''


drillApp.filter 'minutes', ->
  (secs) ->
    return '' unless secs
    secs = parseInt secs

    mins = Math.floor (secs / 60)
    secs = (secs % 60).toString()
    while secs.length < 2
      secs = '0' + secs

    "#{mins}:#{secs}"


drillApp.filter 'minsSecs', ->
  (secs) ->
    mins = Math.floor (secs / 60)
    mstr = if mins > 0 then mins + 'm ' else ''
    mstr + (secs % 60) + 's'


drillApp.filter 'scoreFormat', ['decPlacesFilter', 'minsSecsFilter', (decPlacesFilter, minsSecsFilter) ->
  (score, limitedTime, timeLimit) ->
    score_ = decPlacesFilter score.score, 2
    total = decPlacesFilter score.total, 2
    str = "#{score_} / #{total} pts"

    if limitedTime
      str += ', ' + minsSecsFilter(timeLimit - score.timeLeft)

    str
]


drillApp.filter 'no', ->
  (x, capitalized) ->
    x ? if capitalized then 'No' else 'no'


drillApp.filter 'averageTime', ->
  (questions, timeLimit) ->
    count = 0
    total = 0
    for question in questions
      count += question.scoreLog.length
      for log in question.scoreLog
        total += timeLimit - log.timeLeft

    Math.round (total / count)
