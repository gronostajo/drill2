angular.module('DrillApp').directive 'settingsScreen', ->
  restrict: 'E'
  scope:
    model: '='
    info: '='
    editor: '='
    reset: '='
    continue: '='
  templateUrl: 'app/screens/settings/settings.html'
