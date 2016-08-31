angular.module('DrillApp').controller('QuestionEditorController', function($scope, $window, $timeout, $parse) {
  return new ((function() {
    function _Class() {
      $scope.fileApiSupported = $window.File && $window.FileList && $window.FileReader;
      if ($scope.model == null) {
        $scope.model = {
          value: '',
          visibility: 'full'
        };
      }
      $scope.keypress = this.keypress;
      $scope.submit = this.submit;
    }

    _Class.prototype.keypress = function($event) {
      var enterKey;
      enterKey = ($event.key === '\n') || ($event.keyCode === 10) || ($event.keyCode === 13);
      if ($event.ctrlKey && enterKey) {
        return $timeout(function() {
          return $scope.form.triggerHandler('submit');
        });
      }
    };

    _Class.prototype.submit = function() {
      return $parse($scope.submitExpr)($scope.$parent);
    };

    return _Class;

  })());
});
