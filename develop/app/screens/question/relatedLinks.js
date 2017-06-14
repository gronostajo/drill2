angular.module('DrillApp').directive('relatedLinks', function($uibModal) {
  return {
    restrict: 'A',
    scope: {
      question: '=relatedLinks'
    },
    link: function(scope, element) {
      return element.on('click', function() {
        return $uibModal.open({
          size: 'md',
          scope: scope,
          templateUrl: 'app/screens/question/relatedLinksModal.html'
        });
      });
    }
  };
});
