/*
 *	Drill 2 AngularJS controller
 *	https://github.com/gronostajo/drill2
 */


(function() {

	var app = angular.module('DrillApp', [])

	.controller('DrillController', ['$scope', 'fileReader', function($scope, fileReader) {

		/*
		 *	Constructors
		 */

		$scope.c = {
			question: function (body) {
				this.body = body;
				this.answers = [];

				this.addAnswer = function (body, correct) {
					var answer = new $scope.c.answer(body, correct);
					this.answers.push(answer);
				}

				this.totalCorrect = function () {
					var x = 0;
					for (var i = 0; i < this.answers.length; i++) {
						if (this.answers[i].correct) x++;
					}
					return x;
				}

				this.correct = function () {
					var x = 0;
					for (var i = 0; i < this.answers.length; i++) {
						if (this.answers[i].checked && this.answers[i].correct) x++;
					}
					return x;
				}

				this.incorrect = function () {
					var x = 0;
					for (var i = 0; i < this.answers.length; i++) {
						if (this.answers[i].checked && !this.answers[i].correct) x++;
					}
					return x;
				}

				this.missed = function () {
					var x = 0;
					for (var i = 0; i < this.answers.length; i++) {
						if (!this.answers[i].checked && this.answers[i].correct) x++;
					}
					return x;
				}
			},

			answer: function (body, correct) {
				this.body = body,
				this.correct = !!correct,
				this.checked = false,

				this.reset = function () {
					this.checked = false;
				}
			},

			stats: function () {
				this.correct = 0,
				this.partial = 0,
				this.incorrect = 0,
				this.score = 0,
				this.totalPoints = 0,

				this.totalQuestions = function() {
					return this.correct + this.incorrect + this.partial;
				},
				this.pcOfQuestions = function (num) {
					return (this.totalQuestions())
						? Math.round(num * 100 / this.totalQuestions())
						: 0;
				},

				this.pcScore = function () {
					return (this.totalPoints) ? Math.round(this.score * 100 / this.totalPoints) : 0;
				}
			},

			view: function () {
				this.current = 'first',
				this.isFirst = function () { return this.current == 'first'; },
				this.isNotGraded = function () { return this.current == 'question'; },
				this.isGraded = function () { return this.current == 'graded'; },
				this.isQuestion = function () { return this.isGraded() || this.isNotGraded(); },
				this.isFinal = function () { return this.current == 'end'; }
			},

			perQuestionGrader: function (max, radical) {
				if (typeof radical == 'undefined') radical = true;

				return {
					max: max,

					grade: function (question) {
						ret = {
							score: 0,
							total: this.max
						};

						var correct = question.correct();
						var incorrect = question.incorrect();

						if (radical && (incorrect || !correct)) {
							return ret;
						}

						ret.score = Math.max(max * ((correct - incorrect) / question.totalCorrect()), 0);
						return ret;
					}
				};
			},

			perAnswerGrader: function (radical) {
				if (typeof radical == 'undefined') radical = true;

				return {
					grade: function (question) {
						ret = {
							score: 0,
							total: question.totalCorrect()
						};

						var correct = question.correct();
						var incorrect = question.incorrect();

						if (radical && (incorrect || !correct)) {
							return ret;
						}

						ret.score = Math.max(correct - incorrect, 0);
						return ret;
					}
				};
			}
		};


		/*
		 *	Logic
		 */

		$scope.initialize = function () {
			$scope.softInitialize();

			$scope.fileError = false;
			$scope.dataString = '';

			$scope.pasteEnabled = false;

			$scope.config = {
				shuffleQuestions: true,
				shuffleAnswers: true,

				gradingMethod: 'perQuestion',
				gradingRadical: '1',
				gradingPPQ: 1,		// points per question

				markdown: false
			};
		};

		$scope.softInitialize = function () {
			$scope.questions = [];
			$scope.questionIndex = 0;

			$scope.stats = new $scope.c.stats();
			$scope.view = new $scope.c.view();
		};

		$scope.reinitialize = function () {
			$scope.softInitialize();

			$scope.fileError = false;
			$('#fileSelector').val('').attr('type', 'text').attr('type', 'file');

			if ($scope.fileApiSupported) {
				$('#fileSelector').click();
			}
			else {
				$('#fileContents').focus();
			}
		}

		$scope.restart = function () {
			$scope.softInitialize();

			// clone config
			var config = JSON.parse(JSON.stringify($scope.config));

			$scope.loadQuestions();

			// restore config
			$scope.config = config;
		};

		$scope.setPaste = function (state) {
			$scope.pasteEnabled = !!state;
		};

		$scope.firstQuestion = function () {
			$scope.reorderElements();
			$scope.loadGrader();
			$scope.nextQuestion();
		}

		$scope.nextQuestion = function () {
			$scope.questionIndex++;
			if ($scope.questionIndex > $scope.questions.length) {
				$scope.view.current = 'end';
				return;
			}

			$scope.view.current = 'question';

			var index = $scope.shuffleMap[$scope.questionIndex - 1]
			$scope.currentQuestion = $scope.questions[index];
		};

		$scope.grade = function () {
			$scope.view.current = 'graded';

			var correct = $scope.currentQuestion.correct();
			var incorrect = $scope.currentQuestion.incorrect();
			var missed = $scope.currentQuestion.missed();

			if (incorrect || !correct) $scope.stats.incorrect++;
			else if (missed) $scope.stats.partial++;
			else $scope.stats.correct++;

			var grade = $scope.grader.grade($scope.currentQuestion);
			$scope.currentQuestion.grade = grade;

			$scope.stats.totalPoints += grade.total;
			$scope.stats.score += grade.score;
		};

		$scope.getTextFile = function () {
			fileReader.readAsText($scope.selectedFile, $scope).then(function(result) {
				$scope.dataString = result;
				$scope.loadQuestions();
			});
		};

		$scope.loadQuestions = function (manual) {
			$scope.questions = [];

			// load dummy questions
			// for (var m = 0; m < $scope.dummyQuestions.length; m++) {
			// 	var dq = $scope.dummyQuestions[m];
			// 	var q = new $scope.c.question(dq.body);
			// 	$scope.questions.push(q);

			// 	for (var n = 0; n < dq.answers.length; n++) {
			// 		q.addAnswer(dq.answers[n].body, dq.answers[n].correct);
			// 	}
			// }

			var qs = $scope.dataString.split(/(?:\r?\n){2,}/);

			var options = {
				format: 'legacy',
				markdown: false,
				grading: 'perAnswer',
				radical: true,
				ptsPerQuestion: 1
			};

			var matched = /<options>\s*(\{(?:.|\n|\r)*\})\s*/i.exec(qs[0]);
			if (matched) {
				qs.shift();

				try {
					var loaded = JSON.parse(matched[1]);
				} catch (e) {
					console.error('Invalid <options> object:', matched[1]);
				}

				for (var key in loaded) {
					if (loaded.hasOwnProperty(key) && options.hasOwnProperty(key)) {
						options[key] = loaded[key];
					}
				}
			}

			switch (options.format) {
				case 'legacy':
				case '2':
					$scope.fileFormat = options.format;
					break;

				default:
					$scope.fileFormat = 'unknown';
					break;
			}

			$scope.config.markdownReady = !!options.markdown;
			$scope.config.markdown = $scope.config.markdownReady;

			switch (options.grading.toLowerCase()) {
				case 'perquestion':
				case 'peranswer':
					$scope.config.gradingMethod = options.grading;
					break;

				default:
					$scope.config.gradingMethod = 'perAnswer';
					break;
			}

			$scope.config.gradingRadical = !!options.radical;
			$scope.config.gradingPPQ = parseInt(options.ptsPerQuestion);

			for (var i = 0; i < qs.length; i++) {
				var question = null;

				var body = [];
				var answers = 0;
				var correct = 0;

				var lines = qs[i].split(/(?:\r?\n)/);
				for (var j = 0; j < lines.length; j++) {
					var matched = /^\s*(>+)?([A-Z])\)\s*(.+)$/i.exec(lines[j]);

					if (!matched && !answers) {
						body.push(lines[j]);
					}
					else if (!matched && answers) {
						continue;
					}

					else {
						if (question == null) {
							question = new $scope.c.question(body.join('\n\n'));
						}
						answers++;
						if (matched[1]) {
							correct++;
						}
						question.addAnswer(matched[3], matched[1]);
					}
				}

				if (answers >= 2 && correct >= 1) {
					$scope.questions.push(question);
				}

			}

			$scope.fileError = !$scope.questions.length;
			if ($scope.fileError && !manual) {
				$scope.dataString = '';
			}
		};

		$scope.reorderElements = function () {
			if ($scope.config.shuffleQuestions) {
				$scope.shuffleMap = shuffle(sequence($scope.questions.length));
			}
			else {
				$scope.shuffleMap = sequence($scope.questions.length);
			}

			for (var i = 0; i < $scope.questions.length; i++) {
				var q = $scope.questions[i];
				for (var j = 0; j < q.answers.length; j++) {
					q.answers[j].sortingKey = ($scope.config.shuffleAnswers)
						? Math.random() : j;
				}
			}
		}

		$scope.loadGrader = function () {
			var radical = !!parseInt($scope.config.gradingRadical);
			var ppq = Math.max(parseInt($scope.config.gradingPPQ), 1);

			switch ($scope.config.gradingMethod.toLowerCase()) {
				case 'peranswer':
					$scope.grader = new $scope.c.perAnswerGrader(radical);
					break;

				case 'perquestion':
				default:
					$scope.grader = new $scope.c.perQuestionGrader(ppq, radical);
					break;
			}
		};


		/*
		 *	Initialization
		 */

		$scope.fileApiSupported = window.File && window.FileList && window.FileReader;
		$scope.initialize();
	}])

	.directive('ngReadText', function() {
		return {
			link: function($scope, element) {
				element.bind('change', function(e) {
					$scope.selectedFile = (e.srcElement || e.target).files[0];
					$scope.getTextFile();
				});
			}
		};
	})

	.filter('decPlaces', function() {
		return function (x, dec) {
			var pow = Math.pow(10, dec);
			return (Math.round(x * pow) / pow)
		};
	})

	.filter('markdown', ['$sce', function($sce) {
		return function(str) {
			if (!str) return '';
			var html = markdown.toHTML(str);
			return $sce.trustAsHtml(html);
		};
	}])

	.filter('maybeMarkdown', ['markdownFilter', '$sce', function(markdownFilter, $sce) {
		return function(str, $scope) {
			return $scope.config.markdown ? markdownFilter(str) : $sce.trustAsHtml(str);
		};
	}]);

})();
