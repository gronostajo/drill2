angular.module('DrillApp').service('Answer', function() {
  var Answer;
  return Answer = (function() {
    function Answer(body, correct, id) {
      this.id = id;
      this.body = body.trim();
      this.correct = !!correct;
      this.checked = false;
    }

    Answer.prototype.append = function(line) {
      return this.body += '\n\n' + line.trim();
    };

    Answer.prototype.toString = function() {
      if (this.correct) {
        return "> " + this.id + ") " + this.body + "\n";
      } else {
        return "  " + this.id + ") " + this.body + "\n";
      }
    };

    return Answer;

  })();
});
