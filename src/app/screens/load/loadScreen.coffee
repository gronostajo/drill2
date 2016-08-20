angular.module('DrillApp').directive 'loadScreen', ->
  restrict: 'E'
  scope:
    editorEnabled: '='
    callback: '='
  controller: 'LoadScreenController'
  templateUrl: 'app/screens/load/load.html'
