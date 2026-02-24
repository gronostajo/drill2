angular.module('DrillApp').controller('QuestionEditorController', function($scope, $window, $timeout, $parse) {
  return new (class {
    constructor() {
      this.keypress = this.keypress.bind(this);
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

    keypress($event) {
      var enterKey;
      enterKey = ($event.key === '\n') || ($event.keyCode === 10) || ($event.keyCode === 13);
      if ($event.ctrlKey && enterKey) {
        return $timeout(() => {
          return this.form.triggerHandler('submit');
        });
      }
    }

    submit() {
      return $parse($scope.submitExpr)($scope.$parent);
    }

  })();
});
