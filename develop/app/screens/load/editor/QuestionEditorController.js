angular.module('DrillApp').controller('QuestionEditorController', function($scope, $window, $timeout) {
  return new ((function() {
    function _Class() {
      var base, base1, base2;
      $scope.fileApiSupported = $window.File && $window.FileList && $window.FileReader;
      if ((base = $scope.model).value == null) {
        base.value = '';
      }
      if ((base1 = $scope.model).enabled == null) {
        base1.enabled = !$scope.fileApiSupported;
      }
      if ((base2 = $scope.model).focused == null) {
        base2.focused = false;
      }
      $scope.keypress = this.keypress;
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

    return _Class;

  })());
});
