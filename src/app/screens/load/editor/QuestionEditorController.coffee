angular.module('DrillApp').controller 'QuestionEditorController', ($scope, $window, $timeout) ->
  new class
    constructor: ->
      $scope.fileApiSupported = $window.File && $window.FileList && $window.FileReader
      $scope.model.value ?= ''
      $scope.model.enabled ?= not $scope.fileApiSupported
      $scope.model.focused ?= no

      $scope.keypress = @keypress

    keypress: ($event) ->
      enterKey = ($event.key is '\n') or ($event.keyCode is 10) or ($event.keyCode is 13)
      if $event.ctrlKey and enterKey
        $timeout ->
          $scope.form.triggerHandler('submit')
