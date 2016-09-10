angular.module('DrillApp').controller 'HomeScreenController', ($scope, $window, $uibModal, QuestionLoader) ->
  new class
    constructor: ->
      $scope.fileApiSupported = $window.File && $window.FileList && $window.FileReader

      $scope.editor =
        value: ''
        visibility: if $scope.fileApiSupported then 'none' else 'full'

      $scope.$watch 'editor.visibility', (value) =>
        @clearLoadedData() if value isnt 'mini'

      $scope.loadFromFile = @loadFromFile
      $scope.loadFromString = @loadFromString
      $scope.collapseEditorIfLoaded = @collapseEditorIfLoaded
      $scope.clearLoadedData = @clearLoadedData
      $scope.showLogModal = @showLogModal

    loadFromFile: (file) =>
      return if (not file) or (not $scope.fileApiSupported)
      $scope.file = file
      fileReader = new FileReader()
      fileReader.readAsText(file)
      fileReader.onload = (e) =>
        $scope.editor.value = e.target.result
        @loadFromString($scope.editor.value, file.name)

    loadFromString: (input, filename) =>
      QuestionLoader.loadFromString(input).then (result) ->
        $scope.bank = result.loadedQuestions
        angular.extend($scope.settings, result.config)
        angular.extend($scope.info, result.bankInfo)
        $scope.info.input = input
        $scope.parserLog = result.log
        if $scope.bank.length is 0
          filename ?= 'This input'
          $window.alert("#{filename} doesn't contain any questions.")
        result
      .catch =>
        @clearLoadedData()
        filename ?= 'this'
        $window.alert("Loading failed. Is #{filename} a valid question bank?")

    collapseEditorIfLoaded: ->
      $scope.editor.visibility = 'mini' if $scope.bank.length > 0

    clearLoadedData: ->
      $scope.bank = []
      $scope.info = {}

    showLogModal: (log) ->
      $uibModal.open
        templateUrl: 'app/modal/log.html'
        size: 'md'
        controller: ($scope, log) ->
          $scope.log = log
        resolve:
          log: -> log
