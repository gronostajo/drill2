/*
 *	Drill 2 AngularJS controller
 *	https://github.com/gronostajo/drill2
 */


(function() {

	var drillApp = angular.module('DrillApp', ['ngFileUpload']);


	drillApp.controller('DrillController', function($scope, $timeout, SafeEvalService, GraderFactory, QuestionFactory, AnswerFactory, StatsFactory, ViewFactory) {

		$scope.initialize = function () {
			$scope.fileApiSupported = window.File && window.FileList && window.FileReader;

			$scope.updateStatus = false;
			//noinspection JSUnresolvedVariable
			$(window.applicationCache).on('checking downloading noupdate cached updateready error', function (event) {
				$scope.$apply(function () {
					$scope.updateStatus = event.type.toLowerCase();
				});
			});


			$('#manualInput').keydown(function (e) {
				if (e.ctrlKey && e.keyCode == 13) {
					$('#confirmManualInput').click();
				}
			});

			$scope.softInitialize();

			$scope.fileError = false;
			$scope.dataString = '';

			$scope.pasteEnabled = false;

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
			angular.element(document).ready(function () {
				$.alternate('-');
			});

		};

		$scope.softInitialize = function () {
			$scope.stopTimer();

			$scope.loadedQuestions = [];
			$scope.questions = [];
			$scope.questionIndex = 0;

			$scope.stats = StatsFactory.createStats();
			$scope.view = ViewFactory.createView();
		};

		$scope.reinitialize = function () {
			$scope.softInitialize();

			$scope.fileError = false;
			var $selector = $('#fileSelector');
			$selector.val('').attr('type', 'text').attr('type', 'file');

			if ($scope.pasteEnabled || !$scope.fileApiSupported) {
				$('#manualInput').focus();
			}
			else {
				$selector.click();
			}
		};

		$scope.restart = function () {
			$scope.softInitialize();

			// clone config
			var config = JSON.parse(JSON.stringify($scope.config));

			$scope.loadQuestions();

			// restore config
			$scope.config = config;
		};

		$scope.confirmRestart = function (func) {
			var confirmed = $scope.view.isQuestion()
				? confirm('This will interrupt the test in progress.\nAre you sure?')
				: true;

			if (confirmed) {
				$scope[func]();
			}
		};

		$scope.installUpdate = function () {
			if (window.confirm('The page will be reloaded to install downloaded updates.')) {
				window.location.reload();
			}
		};

		$scope.switchTheme = function () {
			var switchTo = $.alternate()[1];
			$.alternate(switchTo);
		};

		$scope.setPaste = function (state) {
			$scope.pasteEnabled = !!state;
		};

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

			scrollToTop(function() {
				$scope.$apply(function () {
					if ($scope.config.timeLimitEnabled) {
						$scope.currentQuestion.timeLeft = $scope.config.timeLimitSecs;
						$scope.startTimer();
					}
				});
			});

			if ($scope.config.mathjax) {
				$timeout(function () {
					//noinspection JSUnresolvedVariable,JSUnresolvedFunction
					MathJax.Hub.Queue(['Typeset', MathJax.Hub, 'questionView']);
				});
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

		$scope.loadTextFile = function (file) {
			if (file != null) {
				if ($scope.fileApiSupported) {
					$timeout(function() {
						var fileReader = new FileReader();
						fileReader.readAsText(file);
						fileReader.onload = function(e) {
							$timeout(function() {
								$scope.dataString = e.target.result;
								$scope.loadQuestions();
							});
						}
					});
				}
			}
		};

		$scope.loadQuestions = function (manual) {
			$scope.questions = [];
			$scope.loadedQuestions = [];

			var qs = $scope.dataString.split(/(?:\r?\n){2,}/);

			var options = {
				format: 'legacy',
				markdown: false,
				mathjax: false,
				grading: 'perAnswer',
				radical: true,
				ptsPerQuestion: 1,
				timeLimit: 0,
				repeatIncorrect: false,
				explain: 'optional'
			};
			var expl = false;

			//noinspection JSDuplicatedDeclaration
			var matched = /<options>\s*(\{(?:.|\n|\r)*})\s*/i.exec(qs[qs.length - 1]);
			if (matched) {
				qs.pop();

				try {
					var loaded = JSON.parse(matched[1]);
				} catch (e) {
					console.error('Invalid <options> object:', matched[1]);
				}

				for (var key in loaded) {
					if (key == 'explanations') {
						expl = loaded[key];
					}
					else if (options.hasOwnProperty(key)) {
						options[key] = loaded[key];
					}
				}
			}

			switch (options.format) {
				case 'legacy':
				case '2':
				case '2.1':
					$scope.fileFormat = options.format;
					break;

				default:
					$scope.fileFormat = 'unknown';
					break;
			}

			$scope.config.markdownReady = !!options.markdown;
			$scope.config.markdown = $scope.config.markdownReady;

			$scope.config.mathjaxReady = !!options.mathjax;
			$scope.config.mathjax = $scope.config.mathjaxReady;

			$scope.config.customGrader = false;

			if ((options.grading == 'perQuestion') || (options.grading == 'perAnswer')) {
				// for built-in graders, just accept them
				$scope.config.gradingMethod = options.grading;
			}
			else {
				//noinspection JSDuplicatedDeclaration
				var matched = /^custom: *(.+)$/.exec(options.grading);
				if (matched) {
					try {
						SafeEvalService.eval(matched[1], function (id) {
							return (id == 'total') ? 3 : 1;
						});
						$scope.config.gradingMethod = 'custom';
						$scope.config.customGrader = matched[1];
					}
					catch (ex) {
						console.error('Custom grader caused an error when testing.');
					}
				}
				else {
					$scope.config.gradingMethod = 'perAnswer';
				}
			}

			$scope.config.gradingRadical = !!options.radical;
			$scope.config.gradingPPQ = parseInt(options.ptsPerQuestion);

			var secs = (parseInt(options.timeLimit) / 5) * 5;
			if (!secs) {
				$scope.config.timeLimitEnabled = false;
				$scope.config.timeLimitSecs = 60;
			}
			else {
				$scope.config.timeLimitEnabled = true;
				$scope.config.timeLimitSecs = secs;
			}

			$scope.config.repeatIncorrect = !!options.repeatIncorrect;

			if (expl && /summary|optional|always/i.exec(options.explain)) {
				$scope.config.explain = options.explain.toLowerCase();
			}
			else if (expl) {
				$scope.config.explain = 'optional';
			}
			$scope.config.showExplanations = ($scope.config.explain == 'always');

			var rejected = 0;
			for (var i = 0; i < qs.length; i++) {
				var question = null;

				var body = [];
				var answers = 0;
				var correct = 0;
				var id = false;

				var lines = qs[i].split(/(?:\r?\n)/);
				for (var j = 0; j < lines.length; j++) {
					//noinspection JSDuplicatedDeclaration
					var matched = /^\s*(>+)?\s*([A-Z])\)\s*(.+)$/i.exec(lines[j]);

					if (!matched && !answers) {
						if (!body.length) {
							var matchedId = /^\[#([a-zA-Z\d\-+_]+)]\s*(.+)$/.exec(lines[j]);
							if (matchedId) {
								id = matchedId[1];
								lines[j] = matchedId[2];
							}
						}
						body.push(lines[j]);
					}
					else if (!matched && answers) {
						question.appendToLastAnswer(lines[j]);
					}

					else {
						if (question == null) {
							question = QuestionFactory.createQuestion(body.join('\n\n'), id);
						}
						answers++;
						if (matched[1]) {
							correct++;
						}
						question.addAnswer(matched[3], matched[1], matched[2]);
					}
				}

				if (answers >= 2 && correct >= 1) {
					$scope.loadedQuestions.push(question);
				}
				else if (question) {
					console.error('Rejected question with ' + answers + ' answers total, ' + correct + ' correct. Requirement not satisfied: 2 total, 1 correct.', question);
					rejected++;
				}
			}

			if (rejected) {
				console.info(rejected + ' questions rejected.');
			}

			$scope.explanationsAvailable = false;
			if (expl) {
				for (var q = 0; q < $scope.loadedQuestions.length; q++) {
					$scope.loadedQuestions[q].loadExplanation(expl);
					if ($scope.loadedQuestions[q].hasExplanations) {
						$scope.explanationsAvailable = true;
					}
				}
			}

			$scope.fileError = !$scope.loadedQuestions.length;
			if ($scope.fileError && !manual) {
				$scope.dataString = '';
			}
		};

		$scope.reorderElements = function () {
			if ($scope.config.shuffleQuestions) {
				$scope.questions = shuffle($scope.loadedQuestions);
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
			$scope.explanationsAvailable = false;
		};


		$scope.initialize();
	});

})();
