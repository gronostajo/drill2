angular.module('DrillApp').service('ParsingUtils', function() {
  return new (class {
    splitWithNewlines(input) {
      return input.split(/(?:\r?\n)/);
    }

    splitWithDoubleLines(input) {
      return input.split(/(?:\r?\n){2,}/);
    }

    matchAnswer(str) {
      var match;
      // dot doesn't match newlines, [\s\S] matches everything (\S === [^\s])
      match = /^\s*(>+)?\s*([A-Z])\)\s*([\s\S]+)$/i.exec(str);
      if (match) {
        return {
          correct: match[1],
          letter: match[2],
          content: match[3]
        };
      } else {
        return false;
      }
    }

    matchIdentifier(str) {
      var match;
      match = /^\[#([A-Z\d\-+_]+)]\s*([\s\S]*)$/i.exec(str);
      if (match) {
        return {
          identifier: match[1],
          content: match[2]
        };
      } else {
        return false;
      }
    }

  })();
});
