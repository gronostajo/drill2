angular.module('DrillApp').service('QuestionBuilder', function(Question) {
  var QuestionBuilder;
  return QuestionBuilder = (function() {
    QuestionBuilder.prototype.identifier = null;

    QuestionBuilder.prototype.bodyLines = null;

    QuestionBuilder.prototype.question = null;

    QuestionBuilder.prototype.answer = {
      lines: [],
      correct: null,
      identifier: null
    };

    function QuestionBuilder() {
      this.bodyLines = [];
    }

    QuestionBuilder.prototype.setIdentifier = function(identifier) {
      if (this.identifier != null) {
        throw new Error('Identifier already set');
      }
      this.identifier = identifier;
      return this;
    };

    QuestionBuilder.prototype.appendBodyLine = function(line) {
      if (this.question != null) {
        throw new Error('Answers already appended');
      }
      this.bodyLines.push(line);
      return this;
    };

    QuestionBuilder.prototype._buildQuestion = function() {
      return this.question = new Question(this.bodyLines.join('\n\n'), this.identifier);
    };

    QuestionBuilder.prototype._pushAnswer = function() {
      var answerBody;
      answerBody = this.answer.lines.join('\n');
      this.question.addAnswer(answerBody, this.answer.correct, this.answer.identifier);
      return this.answer.lines = [];
    };

    QuestionBuilder.prototype.addAnswer = function(line, correct, identifier) {
      if (this.question == null) {
        this._buildQuestion();
      } else if (this.answer.lines.length) {
        this._pushAnswer();
      }
      this.answer.lines.push(line.trim());
      this.answer.correct = correct;
      this.answer.identifier = identifier;
      return this;
    };

    QuestionBuilder.prototype.appendAnswerLine = function(line) {
      if (!this.answer.lines.length) {
        throw new Error('Answer not created yet');
      }
      this.answer.lines.push(line.trim());
      return this;
    };

    QuestionBuilder.prototype.build = function() {
      if (this.question == null) {
        this._buildQuestion();
      } else if (this.answer.lines.length) {
        this._pushAnswer();
      }
      return this.question;
    };

    return QuestionBuilder;

  })();
});
