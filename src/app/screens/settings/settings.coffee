angular.module('DrillApp').directive 'settings', ->
  restrict: 'E'
  scope:
    model: '='
    info: '='
    fromFile: '='
    reset: '='
  templateUrl: 'app/screens/settings/settings.html'
