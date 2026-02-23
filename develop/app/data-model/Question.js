angular.module('DrillApp').service('Question', function(Answer) {
  var Question;
  return Question = class Question {
    constructor(body1 = '', id1) {
      this.grade = this.grade.bind(this);
      this.body = body1;
      this.id = id1;
      this.explanation = false;
      this.relatedLinks = [];
      this.answers = [];
      this.scoreLog = [];
    }

    addAnswer(body, correct, id) {
      var answer;
      answer = new Answer(body, correct, id);
      return this.answers.push(answer);
    }

    // TODO remove this in favor of QuestionBuilder
    appendToLastAnswer(line) {
      return this.answers[this.answers.length - 1].append(line);
    }

    countAnswers(filter) {
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
    }

    totalCorrect() {
      return this.countAnswers(function(answer) {
        return answer.correct;
      });
    }

    correct() {
      return this.countAnswers(function(answer) {
        return answer.checked && answer.correct;
      });
    }

    incorrect() {
      return this.countAnswers(function(answer) {
        return answer.checked && !answer.correct;
      });
    }

    missed() {
      return this.countAnswers(function(answer) {
        return !answer.checked && answer.correct;
      });
    }

    grade(graderFunction) {
      var grade, time;
      grade = graderFunction(this);
      time = this.timeLeft != null ? this.timeLeft : 0;
      this.scoreLog.push({
        score: grade.score,
        total: grade.total,
        timeLeft: time
      });
      return grade;
    }

    setExplanation(explanation) {
      this.explanation = explanation;
      return this.hasExplanations = true;
    }

    setRelatedLinks(links) {
      return this.relatedLinks = links;
    }

    toString(includeAnswers = true) {
      var answer, body, i, len, ref;
      body = this.id != null ? `[#${this.id}] ${this.body}` : this.body;
      body = body.replace(/\n\n/g, '\n') + '\n';
      if (includeAnswers) {
        ref = this.answers;
        for (i = 0, len = ref.length; i < len; i++) {
          answer = ref[i];
          body += answer.toString();
        }
      }
      return body;
    }

  };
});
