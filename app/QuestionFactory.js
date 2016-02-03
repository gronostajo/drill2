var app;

app = angular.module('DrillApp');

app.factory('QuestionFactory', function(AnswerFactory) {
  return {
    createQuestion: function(body, id) {
      var Question;
      Question = function(body, id) {
        this.body = body;
        this.id = id;
        this.explanation = false;
        this.answers = [];
        this.scoreLog = [];
        this.addAnswer = function(body, correct, id) {
          var answer;
          answer = AnswerFactory.createAnswer(body, correct, id);
          return this.answers.push(answer);
        };
        this.appendToLastAnswer = function(line) {
          return this.answers[this.answers.length - 1].append(line);
        };
        this.totalCorrect = function() {
          var answer, i, len, ref, x;
          x = 0;
          ref = this.answers;
          for (i = 0, len = ref.length; i < len; i++) {
            answer = ref[i];
            if (answer.correct) {
              x++;
            }
          }
          return x;
        };
        this.correct = function() {
          var answer, i, len, ref, x;
          x = 0;
          ref = this.answers;
          for (i = 0, len = ref.length; i < len; i++) {
            answer = ref[i];
            if (answer.checked && answer.correct) {
              x++;
            }
          }
          return x;
        };
        this.incorrect = function() {
          var answer, i, len, ref, x;
          x = 0;
          ref = this.answers;
          for (i = 0, len = ref.length; i < len; i++) {
            answer = ref[i];
            if (answer.checked && !answer.correct) {
              x++;
            }
          }
          return x;
        };
        this.missed = function() {
          var answer, i, len, ref, x;
          x = 0;
          ref = this.answers;
          for (i = 0, len = ref.length; i < len; i++) {
            answer = ref[i];
            if (!answer.checked && answer.correct) {
              x++;
            }
          }
          return x;
        };
        this.grade = function(grader) {
          var grade, time;
          grade = grader(this);
          time = this.hasOwnProperty('timeLeft') ? this.timeLeft : 0;
          this.scoreLog.push({
            score: grade.score,
            total: grade.total,
            timeLeft: time
          });
          return grade;
        };
        this.loadExplanation = function(expl) {
          if (expl.hasOwnProperty(this.id)) {
            this.explanation = expl[this.id];
            return this.hasExplanations = true;
          }
        };
      };
      return new Question(body, id);
    }
  };
});
