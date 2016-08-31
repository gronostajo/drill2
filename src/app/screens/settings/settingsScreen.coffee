angular.module('DrillApp').directive 'settingsScreen', ->
  restrict: 'E'
  scope:
    model: '='
    info: '='
    continue: '='
  templateUrl: 'app/screens/settings/settings.html'
