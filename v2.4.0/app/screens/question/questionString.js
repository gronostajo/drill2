angular.module('DrillApp').directive('questionString', function($uibModal) {
  return {
    restrict: 'A',
    scope: {
      question: '=questionString'
    },
    link: function(scope, element) {
      return element.on('click', function() {
        return $uibModal.open({
          size: 'md',
          scope: scope,
          templateUrl: 'app/screens/question/questionStringModal.html',
          controller: 'QuestionStringModalController'
        });
      });
    }
  };
});
