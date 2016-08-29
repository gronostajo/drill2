angular.module('DrillApp').directive('loadScreen', function() {
  return {
    restrict: 'E',
    scope: {
      editor: '=',
      callback: '='
    },
    controller: 'LoadScreenController',
    templateUrl: 'app/screens/load/load.html'
  };
});
