angular.module('DrillApp').service('QuestionBuilder', function(Question) {
  var QuestionBuilder;
  return QuestionBuilder = (function() {
    class QuestionBuilder {
      constructor() {
        this.bodyLines = [];
      }

      setIdentifier(identifier) {
        if (this.identifier != null) {
          throw new Error('Identifier already set');
        }
        this.identifier = identifier;
        return this;
      }

      appendToBody(line) {
        if (this.question != null) {
          throw new Error('Answers already appended');
        }
        this.bodyLines.push(line);
        return this;
      }

      _buildQuestion() {
        return this.question = new Question(this.bodyLines.join('\n\n'), this.identifier);
      }

      _pushAnswer() {
        var answerBody;
        answerBody = this.answer.lines.join('\n');
        this.question.addAnswer(answerBody, this.answer.correct, this.answer.identifier);
        return this.answer.lines = [];
      }

      addAnswer(line, correct, identifier) {
        if (this.question == null) {
          this._buildQuestion();
        } else if (this.answer.lines.length) {
          this._pushAnswer();
        }
        this.answer.lines.push(line.trim());
        this.answer.correct = correct;
        this.answer.identifier = identifier;
        return this;
      }

      addAnswers(answers) {
        var answer, i, len;
        if (this.question == null) {
          this._buildQuestion();
        } else if (this.answer.lines.length) {
          this._pushAnswer();
        }
        for (i = 0, len = answers.length; i < len; i++) {
          answer = answers[i];
          this.question.addAnswer(answer.body, answer.correct, answer.id);
        }
        return this;
      }

      appendAnswerLine(line) {
        if (!this.answer.lines.length) {
          throw new Error('Answer not created yet');
        }
        this.answer.lines.push(line.trim());
        return this;
      }

      build() {
        if (this.question == null) {
          this._buildQuestion();
        } else if (this.answer.lines.length) {
          this._pushAnswer();
        }
        return this.question;
      }

    };

    QuestionBuilder.prototype.identifier = null;

    QuestionBuilder.prototype.bodyLines = null;

    QuestionBuilder.prototype.question = null;

    QuestionBuilder.prototype.answer = {
      lines: [],
      correct: null,
      identifier: null
    };

    return QuestionBuilder;

  }).call(this);
});
