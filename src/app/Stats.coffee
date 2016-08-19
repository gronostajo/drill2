angular.module('DrillApp').factory 'Stats', ->
  class
    constructor: ->
      @correct = 0
      @partial = 0
      @incorrect = 0
      @score = 0
      @totalPoints = 0

    total: =>
      @correct + @incorrect + @partial
