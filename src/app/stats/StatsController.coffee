angular.module('DrillApp').controller 'StatsController', ($scope) ->
  new class
    constructor: ->
      $scope.total = ->
        $scope.stats.correct + $scope.stats.incorrect + $scope.stats.partial
