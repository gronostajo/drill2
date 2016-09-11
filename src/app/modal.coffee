angular.module('DrillApp').directive 'modal', ($uibModal) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    element.on 'click', ->
      $uibModal.open
        templateUrl: attrs.modal
        size: attrs.size
