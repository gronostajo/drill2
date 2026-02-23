angular.module('DrillApp').controller('QuestionStringModalController', function($scope) {
  return new (class {
    constructor() {
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

  })();
});
