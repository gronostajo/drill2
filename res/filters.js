(function () {

    var drillApp = angular.module('DrillApp');

	drillApp.filter('decPlaces', function () {
		return function (x, dec) {
			var pow = Math.pow(10, dec);
			return (Math.round(x * pow) / pow)
		};
	});

	drillApp.filter('markdown', ['$sce', function ($sce) {
		return function(str, $scope) {
			if (!str || !$scope.config.markdown) return '';

			//noinspection JSUnresolvedVariable
			var parser = new commonmark.Parser();
			//noinspection JSUnresolvedVariable
			var renderer = new commonmark.HtmlRenderer();

			var ast = parser.parse(str);

			// fixes double newlines in code
			var fix = function (node) {
				if (node._type === 'CodeBlock') {
					// fix double newlines
					var str = node._literal;
					if (node._isFenced) str = str.substring(1, str.length - 1);  // fenced code blocks have additional newlines on ends

					var split = str.split('\n');
					var wanted = [];

					for (var i = 0; i < split.length; i += 2) {
						wanted.push(split[i]);
					}

					node._literal = wanted.join('\n');
				}
				else {
					if (node._firstChild) fix(node._firstChild);
					if (node._next) fix(node._next);
				}
			};

			fix(ast);
			var html = renderer.render(ast);

			return $sce.trustAsHtml(html);
		};
	}]);

	drillApp.filter('lines', function () {
		return function(str) {
			if (!str) return [];
			return str.split(/\s*(?:\r?\n)(?:\r?\n\s)*/);
		};
	});

	drillApp.filter('doubleNewlines', function () {
		return function (str) {
			return str ? str.replace(/\n+/g, '\n\n') : '';
		}
	});

	drillApp.filter('minutes', function () {
		return function (secs) {
			if (typeof(secs) == 'undefined') return '';
			secs = parseInt(secs);

			var mins = Math.floor(secs / 60);
			secs = (secs % 60).toString();
			while (secs.length < 2) {
				secs = '0' + secs;
			}

			return mins + ':' + secs;
		}
	});

	drillApp.filter('minsSecs', function () {
		return function (secs) {
			var mins = Math.floor(secs / 60);
			var mstr = (mins > 0) ? mins + 'm ' : '';
			return mstr + (secs % 60) + 's';
		}
	});

	drillApp.filter('scoreFormat', ['decPlacesFilter', 'minsSecsFilter', function (decPlacesFilter, minsSecsFilter) {
		return function (score, limitedTime, timeLimit) {
			var str = decPlacesFilter(score.score, 2) + ' / '
				+ decPlacesFilter(score.total, 2) + ' pts';
			if (limitedTime) {
				str += ', ' + minsSecsFilter(timeLimit - score.timeLeft);
			}
			return str;
		}
	}]);

	drillApp.filter('no', function () {
		return function (x, capitalized) {
			return x ? x : (capitalized ? 'No' : 'no');
		}
	});

	drillApp.filter('averageTime', function () {
		return function (questions, timeLimit) {
			var count = 0;
			var total = 0;

			for (var q = 0; q < questions.length; q++) {
				count += questions[q].scoreLog.length;
				for (var s = 0; s < questions[q].scoreLog.length; s++) {
					total += timeLimit - questions[q].scoreLog[s].timeLeft;
				}
			}

			return Math.round(total / count);
		}
	});

})();