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

    _Class.prototype.assignQuestionExtras = function(options) {
      var explanations, relatedLinks;
      explanations = options.explanations;
      relatedLinks = options.relatedLinks;
      return function(questions, logFn) {
        var commonExplanationIds, commonLinkIds, i, id, j, len, len1, loadedIds, question;
        if (!angular.isArray(questions)) {
          throw new Error('Expected an array of questions');
        }
        if (!angular.isObject(explanations)) {
          throw new Error('Expected a map of explanations');
        }
        if (!angular.isObject(relatedLinks)) {
          throw new Error('Expected a map of related links');
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
        commonExplanationIds = [];
        for (i = 0, len = questions.length; i < len; i++) {
          question = questions[i];
          if (!(question.id in explanations)) {
            continue;
          }
          question.setExplanation(explanations[question.id]);
          commonExplanationIds.push(question.id);
        }
        if (loadedIds.length > commonExplanationIds.length) {
          logFn((loadedIds.length - commonExplanationIds.length) + " explanations couldn't be matched to questions");
        }
        loadedIds = (function() {
          var results;
          results = [];
          for (id in relatedLinks) {
            results.push(id);
          }
          return results;
        })();
        commonLinkIds = [];
        for (j = 0, len1 = questions.length; j < len1; j++) {
          question = questions[j];
          if (!(question.id in relatedLinks)) {
            continue;
          }
          question.setRelatedLinks(relatedLinks[question.id]);
          commonLinkIds.push(question.id);
        }
        if (loadedIds.length > commonLinkIds.length) {
          logFn((loadedIds.length - commonLinkIds.length) + " related links couldn't be matched to questions");
        }
        options.explanationsAvailable = commonExplanationIds.length > 0;
        return questions;
      };
    };

    return _Class;

  })());
});
