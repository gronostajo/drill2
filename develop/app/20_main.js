(function() {

	angular.module('DrillApp', ['ngFileUpload', 'ui.bootstrap', 'ngCookies', 'elif'])

	.controller('DrillController', function($scope, $timeout, $document, $cookies, $q,
											GraderFactory, ViewFactory, shuffleFilter, ViewportHelper, ThemeSwitcher, QuestionLoader) {

		$scope.initialize = function () {
			$scope.updateStatus = false;
			//noinspection JSUnresolvedVariable
			$(window.applicationCache).on('checking downloading noupdate cached updateready error', function (event) {
				$scope.$apply(function () {
					$scope.updateStatus = event.type.toLowerCase();
				});
			});

			$scope.softInitialize();

			$scope.bankInfo = {};

			$scope.keyboardShortcutsEnabled = ($cookies.get('keyboardShortcuts') === 'true');
			$scope.$watch('keyboardShortcutsEnabled', function (newValue) {
				$cookies.put('keyboardShortcuts', newValue ? 'true' : 'false');
			});

			$document.ready(function () {
				var statsPreference = $cookies.get('stats');
				if (!statsPreference) {
					var bootstrapScreenSize = ViewportHelper.getBootstrapBreakpoint();
					statsPreference = (bootstrapScreenSize == 'xs') ? 'collapsed' : 'expanded';
				}

				$scope.statsCollapsed = (statsPreference == 'collapsed');

				$scope.$watch('statsCollapsed', function (collapsed) {
					$cookies.put('stats', collapsed ? 'collapsed' : 'expanded');
				});
			});

			$scope.config = {
				shuffleQuestions: true,
				shuffleAnswers: true

				// Other config fields are set with default or overriden values
				// each time questions are loaded, so no need to initialize them
				// with the app.
			};

			$scope.$watch('view.current', function () {
				if ($scope.config.mathjax && ($scope.view.current == 'end')) {
					$timeout(function () {
						//noinspection JSUnresolvedVariable,JSUnresolvedFunction
						MathJax.Hub.Queue(['Typeset', MathJax.Hub, 'finalView']);
					});
				}

				// apply/remove onbeforeunload event
				var wnd = $(window);
				wnd.off('beforeunload');
				if ($scope.view.isQuestion()) {
					wnd.on('beforeunload', function () {
						return 'Closing this page will interrupt the test.\nAre you sure?';
					});
				}
			});

			// load preferred stylesheet
			angular.element($document).ready(function () {
				ThemeSwitcher.loadFromCookie()
			});

		};

		$scope.softInitialize = function () {
			$scope.stopTimer();

			$scope.loadedQuestions = [];
			$scope.questions = [];
			$scope.questionIndex = 0;

			$scope.stats = {
				correct: 0,
				partial: 0,
				incorrect: 0,
				score: 0,
				totalPoints: 0
			};
			$scope.view = ViewFactory.createView();
		};

		$scope.reload = function () {
			$scope.softInitialize();

			QuestionLoader.loadFromString($scope.bankInfo.input).then(function (result) {
				$scope.loadedQuestions = result.loadedQuestions;
				angular.extend($scope.bankInfo, result.bankInfo);
				// ignore config - keep previous values
			});
		};

		$scope.confirmInterruption = function () {
			var confirmed = $scope.view.isQuestion()
				? confirm('This will interrupt the test in progress.\nAre you sure?')
				: true;

			if (confirmed) {
				$scope.reload();
			}
		};

		$scope.installUpdate = function () {
			if (window.confirm('The page will be reloaded to install downloaded updates.')) {
				window.location.reload();
			}
		};

		$scope.switchTheme = ThemeSwitcher.cycle;

		$scope.firstQuestion = function () {
			$scope.reorderElements();
			$scope.escapeQuestions();
			$scope.loadGrader();
			$scope.nextQuestion();
		};

		$scope.nextQuestion = function () {
			$scope.questionIndex++;
			$scope.config.showExplanations = ($scope.config.explain == 'always');

			if ($scope.questionIndex > $scope.questions.length) {
				$scope.view.current = 'end';
				return;
			}

			$scope.view.current = 'question';

			$scope.currentQuestion = $scope.questions[$scope.questionIndex - 1];

			for (var i = 0; i < $scope.currentQuestion.answers.length; i++) {
				$scope.currentQuestion.answers[i].checked = false;
			}

			ViewportHelper.scrollToTop(function() {
				$scope.$apply(function () {
					if ($scope.config.timeLimitEnabled) {
						$scope.currentQuestion.timeLeft = $scope.config.timeLimitSecs;
						$scope.startTimer();
					}
				});
			});

			if ($scope.config.mathjax) {
				$timeout(function () {
                    $('#questionView').find('.MathJax, .MathJax_Preview, [type="math/tex"]').remove();
					//noinspection JSUnresolvedVariable,JSUnresolvedFunction
					MathJax.Hub.Queue(['Typeset', MathJax.Hub, 'questionView']);
				});
			}
		};

		$scope.handleKeypress = function ($event) {
            if (!$scope.keyboardShortcutsEnabled || !$scope.view.isQuestion()) {
				return;
			}

			var sortingKeys = [],
				i;

			if (typeof $scope.currentQuestion === 'undefined') {
				return;
			}

			if ($event.which == 13) {
				if ($scope.view.isNotGraded()) {
					$scope.grade();
				}
				else {
					$scope.nextQuestion();
				}
			}

			for (i = 0; i < $scope.currentQuestion.answers.length; i++) {
				sortingKeys.push($scope.currentQuestion.answers[i].sortingKey);
			}
			
			sortingKeys.sort();

			for (i = 0; i < $scope.currentQuestion.answers.length; i++) {
				if ($scope.currentQuestion.answers[i].sortingKey === sortingKeys[$event.which - 49]) {
					$scope.currentQuestion.answers[i].checked = !$scope.currentQuestion.answers[i].checked;
				}
			}
		};

		$scope.grade = function () {
			$scope.stopTimer();

			$scope.view.current = 'graded';

			var correct = $scope.currentQuestion.correct();
			var incorrect = $scope.currentQuestion.incorrect();
			var missed = $scope.currentQuestion.missed();

			var grade = $scope.currentQuestion.grade($scope.grader);

			if ($scope.questionIndex <= $scope.loadedQuestions.length) {
				if (incorrect || !correct) $scope.stats.incorrect++;
				else if (missed) $scope.stats.partial++;
				else $scope.stats.correct++;

				$scope.stats.totalPoints += grade.total;
				$scope.stats.score += grade.score;
			}

			if ((grade.score < grade.total) && $scope.config.repeatIncorrect) {
				$scope.questions.push($scope.currentQuestion);
			}
		};

		$scope.reorderElements = function () {
			if ($scope.config.shuffleQuestions) {
				$scope.questions = shuffleFilter($scope.loadedQuestions);
			}
			else {
				$scope.questions = $scope.loadedQuestions.slice(0);	// shallow copy
			}

			for (var i = 0; i < $scope.questions.length; i++) {
				var q = $scope.questions[i];
				for (var j = 0; j < q.answers.length; j++) {
					q.answers[j].sortingKey = ($scope.config.shuffleAnswers)
						? Math.random() : j;
				}
			}
		};

		$scope.escapeQuestions = function () {
			if (!$scope.config.mathjaxReady || !$scope.config.markdown) {
				return;
			}

			for (var q = 0; q < $scope.questions.length; q++) {
				var question = $scope.questions[q];
				var regex = /\$\$(.+)\$\$|\^\^(.+)\^\^/g;

				var escape_func = function (match, group1, group2) {
					var group = group1 || group2;
					var escaped = group.replace(/[\\`*_{}\[\]()#+\-.!]/g, function (token) {
						return '\\' + token;
					});
					var delim = match.substr(0, 2);
					return delim + escaped + delim;
				};

				question.body = question.body.replace(regex, escape_func);
				if (question.explanation) {
					question.explanation = question.explanation.replace(regex, escape_func);
				}
			}
		};

		$scope.loadGrader = function () {
			var radical = !!parseInt($scope.config.gradingRadical);
			var ppq = Math.max(parseInt($scope.config.gradingPPQ), 1);

			switch ($scope.config.gradingMethod.toLowerCase()) {
				case 'peranswer':
					$scope.grader = GraderFactory.createPerAnswerGrader(radical);
					break;

				case 'custom':
					$scope.grader = GraderFactory.createOneLinerGrader($scope.config.customGrader);
					break;

				case 'perquestion':
				default:
					$scope.grader = GraderFactory.createPerQuestionGrader(ppq, radical);
					break;
			}
		};

		$scope.startTimer = function () {
			$scope.stopTimer();
			$scope.timer = window.setInterval(function () {
				$scope.$apply($scope.timerTick);
			}, 1000);
		};

		$scope.stopTimer = function () {
			if (typeof $scope.timer != 'undefined') {
				window.clearInterval($scope.timer);
			}
		};

		$scope.timerTick = function () {
			$scope.currentQuestion.timeLeft--;

			if ($scope.currentQuestion.timeLeft <= 0) {
				for (var i = 0; i < $scope.currentQuestion.answers.length; i++) {
					$scope.currentQuestion.answers[i].checked = false;
				}
				$scope.grade();
				$scope.stopTimer();
			}
		};

		$scope.showAllExplanations = function () {
			for (var q = 0; q < $scope.questions.length; q++) {
				$scope.questions[q].explain = true;
			}
			$scope.bankInfo.explanationsAvailable = false;
		};

		$scope.getStatsMessage = function () {
		    if ($scope.questionIndex <= $scope.loadedQuestions.length) {
                return '';
            } else if ($scope.view.isQuestion()) {
                return 'All questions were already asked once.';
            } else if ($scope.view.isFinal()) {
                return 'Presented score doesn\'t reflect your performance in repeated questions.';
            } else {
                return '';
            }
        };


		$scope.initialize();
	});

})();
