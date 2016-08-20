angular.module('DrillApp').controller 'LoadScreenController', ($scope, $window, $timeout) ->
  new class
    constructor: ->
      $scope.fileApiSupported = $window.File && $window.FileList && $window.FileReader

      $scope.loadTextFile = @loadTextFile
      $scope.loadFromString = @loadFromString

    loadTextFile: (file) =>
      return if (not file) or (not $scope.fileApiSupported)
      $timeout =>
        fileReader = new FileReader()
        fileReader.readAsText(file)
        fileReader.onload = (e) =>
          $timeout =>
            $scope.inputString = e.target.result
            @loadFromString($scope.inputString)

    loadFromString: (input) ->
      $scope.callback(input).then ->
        $scope.fileError = no
      , ->
        $scope.fileError = yes

