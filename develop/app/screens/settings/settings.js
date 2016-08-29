angular.module('DrillApp').directive('settings', function() {
  return {
    restrict: 'E',
    scope: {
      model: '=',
      info: '=',
      fromFile: '=',
      reset: '='
    },
    templateUrl: 'app/screens/settings/settings.html'
  };
});
