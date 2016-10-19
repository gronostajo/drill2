angular.module('DrillApp').controller 'QuestionStringModalController', ($scope) ->
  new class
    constructor: ->
      $scope.view =
        showAnswers: no
        showExplanation: no
      $scope.content =
        withAnswers: $scope.question.toString(yes)
        withoutAnswers: $scope.question.toString(no)
        explanation: $scope.question.explanation or false
