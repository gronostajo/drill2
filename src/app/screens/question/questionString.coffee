angular.module('DrillApp').directive 'questionString', ($uibModal) ->
  restrict: 'A'
  scope:
    question: '=questionString'
  link: (scope, element) ->
    element.on 'click', ->
      $uibModal.open
        size: 'md'
        scope: scope
        templateUrl: 'app/screens/question/questionStringModal.html'
        controller: 'QuestionStringModalController'
