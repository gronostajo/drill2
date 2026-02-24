angular.module('DrillApp').service('Answer', function() {
  var Answer;
  return Answer = class Answer {
    constructor(body, correct, id) {
      this.id = id;
      this.body = body.trim();
      this.correct = !!correct;
      this.checked = false;
    }

    append(line) { // TODO is this used anywhere?
      return this.body += '\n\n' + line.trim();
    }

    toString() {
      if (this.correct) {
        return `> ${this.id}) ${this.body}\n`;
      } else {
        return `  ${this.id}) ${this.body}\n`;
      }
    }

  };
});
