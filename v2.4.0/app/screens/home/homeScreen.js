angular.module('DrillApp').directive('homeScreen', function() {
  return {
    restrict: 'E',
    scope: {
      bank: '=',
      settings: '=',
      info: '=',
      start: '='
    },
    controller: 'HomeScreenController',
    templateUrl: 'app/screens/home/home.html'
  };
});
