angular.module('DrillApp').controller('HomeScreenController', function($scope, $window, $uibModal, QuestionLoader) {
  return new (class {
    constructor() {
      this.loadFromFile = this.loadFromFile.bind(this);
      this.loadFromString = this.loadFromString.bind(this);
      $scope.fileApiSupported = $window.File && $window.FileList && $window.FileReader;
      $scope.editor = {
        value: '',
        visibility: $scope.fileApiSupported ? 'none' : 'full'
      };
      $scope.$watch('editor.visibility', (value) => {
        if (value !== 'mini') {
          return this.clearLoadedData();
        }
      });
      $scope.loadFromFile = this.loadFromFile;
      $scope.loadFromString = this.loadFromString;
      $scope.collapseEditorIfLoaded = this.collapseEditorIfLoaded;
      $scope.clearLoadedData = this.clearLoadedData;
      $scope.showLogModal = this.showLogModal;
    }

    loadFromFile(file) {
      var fileReader;
      if ((!file) || (!$scope.fileApiSupported)) {
        return;
      }
      $scope.file = file;
      fileReader = new FileReader();
      fileReader.readAsText(file);
      return fileReader.onload = (e) => {
        $scope.editor.value = e.target.result;
        return this.loadFromString($scope.editor.value, file.name);
      };
    }

    loadFromString(input, filename) {
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
          $window.alert(`${filename} doesn't contain any questions.`);
        }
        return result;
      }).catch(() => {
        this.clearLoadedData();
        if (filename == null) {
          filename = 'this';
        }
        return $window.alert(`Loading failed. Is ${filename} a valid question bank?`);
      });
    }

    collapseEditorIfLoaded() {
      if ($scope.bank.length > 0) {
        return $scope.editor.visibility = 'mini';
      }
    }

    clearLoadedData() {
      $scope.bank = [];
      $scope.info = {};
      $scope.parserLog = [];
      return $scope.file = null;
    }

    showLogModal(log) {
      return $uibModal.open({
        templateUrl: 'app/screens/home/logModal.html',
        size: 'md',
        controller: function($scope, log) {
          return $scope.log = log;
        },
        resolve: {
          log: function() {
            return log;
          }
        }
      });
    }

  })();
});
