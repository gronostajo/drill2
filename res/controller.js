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
			}
		}


		/*
		 *	Logic
		 */

		$scope.initialize = function () {
			$scope.softInitialize();

			$scope.config = {
				shuffleQuestions: true,
				shuffleAnswers: true
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
			$('#fileSelector').click();
		}

		$scope.restart = function () {
			$scope.softInitialize();
			$scope.loadDatabase();
		};

		$scope.nextQuestion = function () {
			$scope.questionIndex++;
			if ($scope.questionIndex > $scope.questions.length) {
				$scope.view.current = 'end';
				return;
			}

			$scope.view.current = 'question';

			var index = $scope.shuffleMap[$scope.questionIndex - 1]
			$scope.currentQuestion = $scope.questions[index];

			$('#questionBody').html(markdown.toHTML($scope.currentQuestion.body));
		};

		$scope.grade = function () {
			$scope.view.current = 'graded';

			var correct = $scope.currentQuestion.correct();
			var incorrect = $scope.currentQuestion.incorrect();
			var missed = $scope.currentQuestion.missed();

			if (incorrect || !correct) $scope.stats.incorrect++;
			else if (missed) $scope.stats.partial++;
			else $scope.stats.correct++;

			$scope.stats.totalPoints += correct + missed;
			if (!incorrect) $scope.stats.score += correct;
		};

		$scope.getTextFile = function () {
			fileReader.readAsText($scope.selectedFile, $scope).then(function(result) {
				$scope.datastring = result;
				$scope.loadDatabase();
			});
		};

		$scope.loadDatabase = function () {
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

			var qs = $scope.datastring.split(/(?:\r?\n){2,}/);
			for (var i = 0; i < qs.length; i++) {
				var question = null;

				var body = [];
				var answers = 0;

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
						question.addAnswer(matched[3], matched[1]);
					}
				}

				if (answers >= 2) {
					$scope.questions.push(question);
				}

			}

			$scope.reorderElements();
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


		/*
		 *	Initialization
		 */

		$scope.isSupported = window.File && window.FileList && window.FileReader;
		$scope.initialize();
	}])

	.directive('readText', function() {
		return {
			link: function($scope, element) {
				element.bind('change', function(e) {
					$scope.selectedFile = (e.srcElement || e.target).files[0];
					$scope.getTextFile();
				});
			}
		};
	});

})();
