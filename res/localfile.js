/*
 *	Drill 2 AngularJS upload module
 *	Adapted from: http://odetocode.com/blogs/scott/archive/2013/07/03/building-a-filereader-service-for-angularjs-the-service.aspx
 *	https://github.com/gronostajo/drill2
 */


(function (module) {

	module.factory('fileReader', ['$q', function ($q) {

		var onLoad = function(reader, deferred, scope) {
			return function () {
				scope.$apply(function () {
					deferred.resolve(reader.result);
				});
			};
		};

		var onError = function (reader, deferred, scope) {
			return function () {
				scope.$apply(function () {
					deferred.reject(reader.result);
				});
			};
		};

		var getReader = function(deferred, scope) {
			var reader = new FileReader();
			reader.onload = onLoad(reader, deferred, scope);
			reader.onerror = onError(reader, deferred, scope);
			return reader;
		};

		var readAsText = function (file, scope) {
			var deferred = $q.defer();

			var reader = getReader(deferred, scope);
			reader.readAsText(file);

			return deferred.promise;
		};

		return {
			readAsText: readAsText
		};
	}]);

}(angular.module('DrillApp')));
