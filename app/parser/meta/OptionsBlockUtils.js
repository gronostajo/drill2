angular.module('DrillApp').service('OptionsBlockUtils', function(OptionsBlockProcessor) {
  var optionsBlockRegex;
  optionsBlockRegex = /<options>\s*(\{(?:.|\n|\r)*})\s*/i;
  return new ((function() {
    function _Class() {}

    _Class.prototype.loadOptions = function(target) {
      return function(parts, logFn) {
        var defaults, lastPart, matched, options, optionsString;
        if (!angular.isArray(parts)) {
          throw new Error('Expected an array as input');
        }
        if (!angular.isObject(target)) {
          throw new Error('Expected an object as target');
        }
        if (parts.length === 0) {
          return parts;
        }
        lastPart = parts[parts.length - 1];
        if (!(matched = optionsBlockRegex.exec(lastPart))) {
          defaults = OptionsBlockProcessor.process('{}');
          angular.extend(target, defaults);
          return parts;
        }
        optionsString = matched[1];
        options = OptionsBlockProcessor.process(optionsString, logFn);
        angular.extend(target, options);
        return parts.slice(0, parts.length - 1);
      };
    };

    _Class.prototype.assignExplanations = function(options) {
      var explanations;
      explanations = options.explanations;
      return function(questions, logFn) {
        var commonIds, i, id, len, loadedIds, question;
        if (!angular.isArray(questions)) {
          throw new Error('Expected an array of questions');
        }
        if (!angular.isObject(explanations)) {
          throw new Error('Expected a map of explanations');
        }
        if (questions.length === 0) {
          return questions;
        }
        loadedIds = (function() {
          var results;
          results = [];
          for (id in explanations) {
            results.push(id);
          }
          return results;
        })();
        commonIds = [];
        for (i = 0, len = questions.length; i < len; i++) {
          question = questions[i];
          if (!(question.id in explanations)) {
            continue;
          }
          question.loadExplanation(explanations);
          commonIds.push(question.id);
        }
        if (loadedIds.length > commonIds.length) {
          logFn((loadedIds.length - commonIds.length) + " explanations couldn't be matched to questions");
        }
        options.explanationsAvailable = commonIds.length > 0;
        return questions;
      };
    };

    return _Class;

  })());
});
