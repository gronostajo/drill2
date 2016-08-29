angular.module('DrillApp').controller('StatsController', function($scope) {
  return new ((function() {
    function _Class() {
      $scope.total = function() {
        return $scope.stats.correct + $scope.stats.incorrect + $scope.stats.partial;
      };
    }

    return _Class;

  })());
});
