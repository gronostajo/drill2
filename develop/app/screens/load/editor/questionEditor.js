angular.module('DrillApp').directive('questionEditor', function() {
  return {
    restrict: 'E',
    scope: {
      model: '=',
      submit: '='
    },
    templateUrl: 'app/screens/load/editor/editor.html',
    controller: 'QuestionEditorController'
  };
}).directive('questionEditorTextarea', function() {
  return {
    restrict: 'A',
    scope: false,
    link: function(scope, element) {
      element.bind('focus', function() {
        return scope.$apply('model.focused=true');
      });
      return element.bind('blur', function() {
        return scope.$apply('model.focused=false');
      });
    }
  };
}).directive('questionEditorForm', function() {
  return {
    restrict: 'A',
    scope: false,
    link: function(scope, element) {
      return scope.form = element;
    }
  };
});
