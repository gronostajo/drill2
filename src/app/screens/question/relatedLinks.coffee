angular.module('DrillApp').directive 'relatedLinks', ($uibModal) ->
  restrict: 'A'
  scope:
    question: '=relatedLinks'
  link: (scope, element) ->
    element.on 'click', ->
      $uibModal.open
        size: 'md'
        scope: scope
        templateUrl: 'app/screens/question/relatedLinksModal.html'
