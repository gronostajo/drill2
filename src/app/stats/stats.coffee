angular.module('DrillApp').directive 'stats', ->
  restrict: 'E'
  scope:
    stats: '='
    progress: '='
    questionCount: '='
    collapsed: '='
    message: '='
    showDistribution: '='
  controller: 'StatsController'
  templateUrl: 'app/stats/stats.html'
