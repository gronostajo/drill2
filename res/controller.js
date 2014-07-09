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
				this.scoreLog = [];

				this.addAnswer = function (body, correct) {
					var answer = new $scope.c.answer(body, correct);
					this.answers.push(answer);
				};

				this.totalCorrect = function () {
					var x = 0;
					for (var i = 0; i < this.answers.length; i++) {
						if (this.answers[i].correct) x++;
					}
					return x;
				};

				this.correct = function () {
					var x = 0;
					for (var i = 0; i < this.answers.length; i++) {
						if (this.answers[i].checked && this.answers[i].correct) x++;
					}
					return x;
				};

				this.incorrect = function () {
					var x = 0;
					for (var i = 0; i < this.answers.length; i++) {
						if (this.answers[i].checked && !this.answers[i].correct) x++;
					}
					return x;
				};

				this.missed = function () {
					var x = 0;
					for (var i = 0; i < this.answers.length; i++) {
						if (!this.answers[i].checked && this.answers[i].correct) x++;
					}
					return x;
				};

				this.grade = function (grader) {
					var grade = grader.grade(this);
					var time = this.hasOwnProperty('timeLeft')
						? this.timeLeft : 0;

					this.scoreLog.push({
						score: grade.score,
						total: grade.total,
						timeLeft: time
					});

					return grade;
				};
			},

			answer: function (body, correct) {
				this.body = body;
				this.correct = !!correct;
				this.checked = false;

				this.reset = function () {
					this.checked = false;
				};
			},

			stats: function () {
				this.correct = 0;
				this.partial = 0;
				this.incorrect = 0;
				this.score = 0;
				this.totalPoints = 0;

				this.totalQuestions = function() {
					return this.correct + this.incorrect + this.partial;
				};

				this.pcOfQuestions = function (num) {
					return (this.totalQuestions())
						? Math.round(num * 100 / this.totalQuestions())
						: 0;
				};

				this.pcScore = function () {
					return (this.totalPoints) ? Math.round(this.score * 100 / this.totalPoints) : 0;
				};
			},

			view: function () {
				this.current = 'first';
				this.isFirst = function () { return this.current == 'first'; };
				this.isNotGraded = function () { return this.current == 'question'; };
				this.isGraded = function () { return this.current == 'graded'; };
				this.isQuestion = function () { return this.isGraded() || this.isNotGraded(); };
				this.isFinal = function () { return this.current == 'end'; };
			},

			perQuestionGrader: function (max, radical) {
				if (typeof radical == 'undefined') radical = true;

				return {
					max: max,

					grade: function (question) {
						var ret = {
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
						var ret = {
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
			},

			oneLinerGrader: function (oneliner) {
				return {
					grade: function (question) {
						var questionInfo = function (id) {
							switch (id) {
								case 'correct':
									return question.correct();
									break;

								case 'incorrect':
									return question.incorrect();
									break;

								case 'missed':
									return question.missed();
									break;

								case 'total':
									return question.totalCorrect();
									break;
							}
						};

						var fakeInfo = function (id) {
							switch (id) {
								case 'correct':
								case 'total':
									return question.totalCorrect();
									break;

								case 'incorrect':
								case 'missed':
									return 0;
									break;
							}
						};

						return {
							score: SafeEval(oneliner, questionInfo),
							total: SafeEval(oneliner, fakeInfo)
						};
					}
				}
			}
		};


		/*
		 *	Logic
		 */

		$scope.initialize = function () {
			$scope.fileApiSupported = window.File && window.FileList && window.FileReader;

			$scope.updateStatus = false;
			$(window.applicationCache).on('checking downloading noupdate cached updateready', function (event) {
				$scope.$apply(function () {
					$scope.updateStatus = event.type.toLowerCase();
				});
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
		};

		$scope.softInitialize = function () {
			$scope.stopTimer();

			$scope.loadedQuestions = [];
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

		$scope.installUpdate = function () {
			if (window.confirm('The page will be reloaded to install downloaded updates.')) {
				window.location.reload();
			}
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

			$scope.currentQuestion = $scope.questions[$scope.questionIndex - 1];

			for (var i = 0; i < $scope.currentQuestion.answers.length; i++) {
				$scope.currentQuestion.answers[i].checked = false;
			}

			if ($scope.config.timeLimitEnabled) {
				$scope.currentQuestion.timeLeft = $scope.config.timeLimitSecs;
				$scope.startTimer();
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

		$scope.getTextFile = function () {
			fileReader.readAsText($scope.selectedFile, $scope).then(function(result) {
				$scope.dataString = result;
				$scope.loadQuestions();
			});
		};

		$scope.loadQuestions = function (manual) {
			$scope.questions = [];
			$scope.loadedQuestions = [];

			var qs = $scope.dataString.split(/(?:\r?\n){2,}/);

			var options = {
				format: 'legacy',
				markdown: false,
				grading: 'perAnswer',
				radical: true,
				ptsPerQuestion: 1,
				timeLimit: 0,
				repeatIncorrect: false
			};

			var matched = /<options>\s*(\{(?:.|\n|\r)*\})\s*/i.exec(qs[qs.length - 1]);
			if (matched) {
				qs.pop();

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

			$scope.config.customGrader = false;
			switch (options.grading.toLowerCase()) {
				case 'perquestion':
				case 'peranswer':
					$scope.config.gradingMethod = options.grading;
					break;

				default:
					var matched = /^custom: +(.+)$/.exec(options.grading)
					if (matched) {
						try {
							SafeEval(matched[1], function (id) {
								return (id == 'total') ? 3 : 1;
							});
							$scope.config.gradingMethod = 'custom';
							$scope.config.customGrader = matched[1];
							break;
						}
						catch (ex) {
							console.error('Custom grader caused an error when testing.');
						}
					}
					$scope.config.gradingMethod = 'perAnswer';
					break;
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
					$scope.loadedQuestions.push(question);
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

		$scope.loadGrader = function () {
			var radical = !!parseInt($scope.config.gradingRadical);
			var ppq = Math.max(parseInt($scope.config.gradingPPQ), 1);

			switch ($scope.config.gradingMethod.toLowerCase()) {
				case 'peranswer':
					$scope.grader = new $scope.c.perAnswerGrader(radical);
					break;

				case 'custom':
					$scope.grader = new $scope.c.oneLinerGrader($scope.config.customGrader);
					break;

				case 'perquestion':
				default:
					$scope.grader = new $scope.c.perQuestionGrader(ppq, radical);
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


		$scope.initialize();
	}])

	.directive('ngReadText', function () {
		return {
			link: function($scope, element) {
				element.bind('change', function(e) {
					$scope.selectedFile = (e.srcElement || e.target).files[0];
					$scope.getTextFile();
				});
			}
		};
	})

	.filter('decPlaces', function () {
		return function (x, dec) {
			var pow = Math.pow(10, dec);
			return (Math.round(x * pow) / pow)
		};
	})

	.filter('markdown', ['$sce', function ($sce) {
		return function(str) {
			if (!str) return '';
			var html = markdown.toHTML(str);
			return $sce.trustAsHtml(html);
		};
	}])

	.filter('lines', ['$sce', function ($sce) {
		return function(str) {
			if (!str) return [];
			return str.split(/\s*(\r?\n)(\r?\n\s)*/);
		};
	}])

	.filter('minutes', function () {
		return function (secs) {
			secs = parseInt(secs);

			var mins = Math.floor(secs / 60);
			secs = (secs % 60).toString();
			while (secs.length < 2) {
				secs = '0' + secs;
			}

			return mins + ':' + secs;
		}
	})

	.filter('minsSecs', function () {
		return function (secs) {
			var mins = Math.floor(secs / 60);
			var mstr = (mins > 0) ? mins + 'm ' : '';
			return mstr + (secs % 60) + 's';
		}
	})

	.filter('scoreFormat', ['decPlacesFilter', 'minsSecsFilter', function (decPlacesFilter, minsSecsFilter) {
		return function (score, limitedTime, timeLimit) {
			var str = decPlacesFilter(score.score, 2) + ' / '
				+ decPlacesFilter(score.total, 2) + ' pts';
			if (limitedTime) {
				str += ', ' + minsSecsFilter(timeLimit - score.timeLeft);
			}
			return str;
		}
	}])

	.filter('no', function () {
		return function (x, capitalized) {
			return x ? x : (capitalized ? 'No' : 'no');
		}
	})

	.filter('averageTime', function () {
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
