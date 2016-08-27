angular.module('DrillApp').directive 'loadScreen', ->
  restrict: 'E'
  scope:
    editor: '='
    callback: '='
  controller: 'LoadScreenController'
  templateUrl: 'app/screens/load/load.html'
