angular.module('DrillApp').directive('glyphicon', function() {
  return {
    restrict: 'E',
    replace: true,
    template: '<i class="glyphicon"></i>',
    link: function(scope, element, attr) {
      return attr.$observe('icon', function(newValue, oldValue) {
        if (oldValue) {
          element.removeClass("glyphicon-" + oldValue);
        }
        if (newValue) {
          return element.addClass("glyphicon-" + newValue);
        }
      });
    }
  };
});
