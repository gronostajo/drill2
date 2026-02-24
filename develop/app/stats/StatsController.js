angular.module('DrillApp').controller('StatsController', function($scope) {
  return new (class {
    constructor() {
      $scope.total = function() {
        return $scope.stats.correct + $scope.stats.incorrect + $scope.stats.partial;
      };
    }

  })();
});
