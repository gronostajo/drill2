angular.module('DrillApp').directive('settingsScreen', function() {
  return {
    restrict: 'E',
    scope: {
      model: '=',
      info: '=',
      editor: '=',
      reset: '=',
      "continue": '='
    },
    templateUrl: 'app/screens/settings/settings.html'
  };
});
