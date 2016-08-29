angular.module('DrillApp').service('ParsingUtils', function() {
  return new ((function() {
    function _Class() {}

    _Class.prototype.splitWithNewlines = function(input) {
      return input.split(/(?:\r?\n)/);
    };

    _Class.prototype.splitWithDoubleLines = function(input) {
      return input.split(/(?:\r?\n){2,}/);
    };

    _Class.prototype.matchAnswer = function(str) {
      var match;
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
    };

    _Class.prototype.matchIdentifier = function(str) {
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
    };

    return _Class;

  })());
});
