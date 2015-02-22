app = angular.module 'DrillApp'


app.factory 'StatsFactory', ->
  createStats: ->

    Stats = ->
      @correct = 0
      @partial = 0
      @incorrect = 0
      @score = 0
      @totalPoints = 0

      @totalQuestions = ->
        @correct + @incorrect + @partial

      @pcOfQuestions = (num) ->
        if @totalQuestions() then Math.round (num * 100 / @totalQuestions()) else 0

      @pcScore = ->
        if @totalPoints then Math.round (@score * 100 / @totalPoints) else 0

      return

    new Stats()
