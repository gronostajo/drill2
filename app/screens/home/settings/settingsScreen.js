angular.module('DrillApp').directive('settingsScreen', function() {
  return {
    restrict: 'E',
    scope: {
      model: '=',
      info: '=',
      "continue": '='
    },
    templateUrl: 'app/screens/home/settings/settings.html'
  };
});
