angular.module('DrillApp').directive 'stats', ->
  restrict: 'E'
  scope:
    stats: '='
    progress: '='
    questionCount: '='
    collapsed: '='
    message: '='
  controller: 'StatsController'
  templateUrl: 'app/stats/stats.html'
