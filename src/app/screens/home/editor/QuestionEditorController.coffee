angular.module('DrillApp').controller 'QuestionEditorController', ($scope, $window, $timeout, $parse) ->
  new class
    constructor: ->
      $scope.fileApiSupported = $window.File && $window.FileList && $window.FileReader
      $scope.model ?=
        value: ''
        visibility: 'full'

      $scope.keypress = @keypress
      $scope.submit = @submit

    keypress: ($event) ->
      enterKey = ($event.key is '\n') or ($event.keyCode is 10) or ($event.keyCode is 13)
      if $event.ctrlKey and enterKey
        $timeout ->
          $scope.form.triggerHandler('submit')

    submit: ->
      $parse($scope.submitExpr)($scope.$parent)
