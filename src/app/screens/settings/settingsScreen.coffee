angular.module('DrillApp').directive 'settingsScreen', ->
  restrict: 'E'
  scope:
    model: '='
    info: '='
    editorEnabled: '='
    reset: '='
    continue: '='
  templateUrl: 'app/screens/settings/settings.html'
