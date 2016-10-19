angular.module('DrillApp').directive 'homeScreen', ->
  restrict: 'E'
  scope:
    bank: '='
    settings: '='
    info: '='
    start: '='
  controller: 'HomeScreenController'
  templateUrl: 'app/screens/home/home.html'
