angular.module('DrillApp').controller('QuestionStringModalController', function($scope) {
  return new ((function() {
    function _Class() {
      $scope.view = {
        showAnswers: false,
        showExplanation: false
      };
      $scope.content = {
        withAnswers: $scope.question.toString(true),
        withoutAnswers: $scope.question.toString(false),
        explanation: $scope.question.explanation || false
      };
    }

    return _Class;

  })());
});
