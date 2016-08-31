var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('DrillApp').controller('HomeScreenController', function($scope, $window, QuestionLoader) {
  return new ((function() {
    function _Class() {
      this.loadFromString = bind(this.loadFromString, this);
      this.loadFromFile = bind(this.loadFromFile, this);
      $scope.fileApiSupported = $window.File && $window.FileList && $window.FileReader;
      $scope.editor = {
        value: '',
        visibility: $scope.fileApiSupported ? 'none' : 'full'
      };
      $scope.$watch('editor.visibility', (function(_this) {
        return function(value) {
          if (value !== 'mini') {
            return _this.clearLoadedData();
          }
        };
      })(this));
      $scope.loadFromFile = this.loadFromFile;
      $scope.loadFromString = this.loadFromString;
      $scope.collapseEditorIfLoaded = this.collapseEditorIfLoaded;
      $scope.clearLoadedData = this.clearLoadedData;
    }

    _Class.prototype.loadFromFile = function(file) {
      var fileReader;
      if ((!file) || (!$scope.fileApiSupported)) {
        return;
      }
      $scope.file = file;
      fileReader = new FileReader();
      fileReader.readAsText(file);
      return fileReader.onload = (function(_this) {
        return function(e) {
          $scope.editor.value = e.target.result;
          return _this.loadFromString($scope.editor.value, file.name);
        };
      })(this);
    };

    _Class.prototype.loadFromString = function(input, filename) {
      return QuestionLoader.loadFromString(input).then(function(result) {
        $scope.bank = result.loadedQuestions;
        angular.extend($scope.settings, result.config);
        angular.extend($scope.info, result.bankInfo);
        $scope.info.input = input;
        $scope.parserLog = result.log;
        if ($scope.bank.length === 0) {
          if (filename == null) {
            filename = 'This input';
          }
          $window.alert(filename + " doesn't contain any questions.");
        }
        return result;
      })["catch"]((function(_this) {
        return function() {
          _this.clearLoadedData();
          if (filename == null) {
            filename = 'this';
          }
          return $window.alert("Loading failed. Is " + filename + " a valid question bank?");
        };
      })(this));
    };

    _Class.prototype.collapseEditorIfLoaded = function() {
      if ($scope.bank.length > 0) {
        return $scope.editor.visibility = 'mini';
      }
    };

    _Class.prototype.clearLoadedData = function() {
      $scope.bank = [];
      return $scope.info = {};
    };

    return _Class;

  })());
});
