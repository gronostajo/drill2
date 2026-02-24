angular.module('DrillApp').directive('stats', function() {
  return {
    restrict: 'E',
    scope: {
      stats: '=',
      progress: '=',
      questionCount: '=',
      collapsed: '=',
      message: '=',
      showDistribution: '='
    },
    controller: 'StatsController',
    templateUrl: 'app/stats/stats.html'
  };
});
