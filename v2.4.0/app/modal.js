angular.module('DrillApp').directive('modal', function($uibModal) {
  return {
    restrict: 'A',
    link: function(scope, element, attrs) {
      return element.on('click', function() {
        return $uibModal.open({
          templateUrl: attrs.modal,
          size: attrs.size
        });
      });
    }
  };
});
