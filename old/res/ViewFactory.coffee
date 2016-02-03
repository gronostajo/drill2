app = angular.module 'DrillApp'


app.factory 'ViewFactory', ->
  createView: ->

    View = ->
      @current = 'first'

      @isFirst = -> @current == 'first'
      @isNotGraded = -> @current == 'question'
      @isGraded = -> @current == 'graded'
      @isQuestion = -> @isGraded() or @isNotGraded()
      @isFinal = -> @current == 'end'

      return

    new View()