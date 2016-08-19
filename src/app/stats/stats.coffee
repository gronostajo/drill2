angular.module('DrillApp').directive 'stats', ->
  restrict: 'E'
  scope:
    stats: '='
    collapsed: '='
    message: '='
  controller: 'StatsController'
  templateUrl: 'app/stats/stats.html'
