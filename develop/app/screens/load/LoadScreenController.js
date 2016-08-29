var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('DrillApp').controller('LoadScreenController', function($scope, $window, $timeout) {
  return new ((function() {
    function _Class() {
      this.loadTextFile = bind(this.loadTextFile, this);
      $scope.fileApiSupported = $window.File && $window.FileList && $window.FileReader;
      $scope.loadTextFile = this.loadTextFile;
      $scope.loadFromString = this.loadFromString;
    }

    _Class.prototype.loadTextFile = function(file) {
      if ((!file) || (!$scope.fileApiSupported)) {
        return;
      }
      return $timeout((function(_this) {
        return function() {
          var fileReader;
          fileReader = new FileReader();
          fileReader.readAsText(file);
          return fileReader.onload = function(e) {
            return $timeout(function() {
              $scope.inputString = e.target.result;
              return _this.loadFromString($scope.inputString);
            });
          };
        };
      })(this));
    };

    _Class.prototype.loadFromString = function(input) {
      return $scope.callback(input).then(function() {
        return $scope.fileError = false;
      }, function() {
        return $scope.fileError = true;
      });
    };

    return _Class;

  })());
});
