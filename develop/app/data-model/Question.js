var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('DrillApp').service('Question', function(Answer) {
  var Question;
  return Question = (function() {
    function Question(body1, id1) {
      this.body = body1 != null ? body1 : '';
      this.id = id1;
      this.grade = bind(this.grade, this);
      this.explanation = false;
      this.answers = [];
      this.scoreLog = [];
    }

    Question.prototype.addAnswer = function(body, correct, id) {
      var answer;
      answer = new Answer(body, correct, id);
      return this.answers.push(answer);
    };

    Question.prototype.appendToLastAnswer = function(line) {
      return this.answers[this.answers.length - 1].append(line);
    };

    Question.prototype.countAnswers = function(filter) {
      var answer, count, i, len, ref;
      count = 0;
      ref = this.answers;
      for (i = 0, len = ref.length; i < len; i++) {
        answer = ref[i];
        if (filter(answer)) {
          count++;
        }
      }
      return count;
    };

    Question.prototype.totalCorrect = function() {
      return this.countAnswers(function(answer) {
        return answer.correct;
      });
    };

    Question.prototype.correct = function() {
      return this.countAnswers(function(answer) {
        return answer.checked && answer.correct;
      });
    };

    Question.prototype.incorrect = function() {
      return this.countAnswers(function(answer) {
        return answer.checked && !answer.correct;
      });
    };

    Question.prototype.missed = function() {
      return this.countAnswers(function(answer) {
        return !answer.checked && answer.correct;
      });
    };

    Question.prototype.grade = function(graderFunction) {
      var grade, time;
      grade = graderFunction(this);
      time = this.timeLeft != null ? this.timeLeft : 0;
      this.scoreLog.push({
        score: grade.score,
        total: grade.total,
        timeLeft: time
      });
      return grade;
    };

    Question.prototype.loadExplanation = function(explanation) {
      if (explanation[this.id] != null) {
        this.explanation = explanation[this.id];
        return this.hasExplanations = true;
      }
    };

    Question.prototype.toString = function(includeAnswers) {
      var answer, body, i, len, ref;
      if (includeAnswers == null) {
        includeAnswers = true;
      }
      body = this.id != null ? "[#" + this.id + "] " + this.body : this.body;
      body = body.replace(/\n\n/g, '\n') + '\n';
      if (includeAnswers) {
        ref = this.answers;
        for (i = 0, len = ref.length; i < len; i++) {
          answer = ref[i];
          body += answer.toString();
        }
      }
      return body;
    };

    return Question;

  })();
});
