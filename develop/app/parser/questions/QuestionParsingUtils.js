angular.module('DrillApp').service('QuestionParsingUtils', function(ParsingUtils, QuestionBuilder, QuestionMerger) {
  var excerpt;
  excerpt = function(question, limit) {
    var body;
    if (limit == null) {
      limit = 40;
    }
    body = question.body.trim();
    if (body.length > limit) {
      return body.substring(0, limit) + '...';
    } else if (body.length === 0) {
      return '[no body]';
    } else {
      return body;
    }
  };
  return new ((function() {
    function _Class() {}

    _Class.prototype.parseQuestion = function(str) {
      var answerMatch, builder, i, identifierMatched, len, line, lines, parsingAnswers;
      lines = ParsingUtils.splitWithNewlines(str);
      builder = new QuestionBuilder();
      if ((identifierMatched = ParsingUtils.matchIdentifier(lines[0]))) {
        lines = lines.slice(1);
        builder.appendToBody(identifierMatched.content);
        builder.setIdentifier(identifierMatched.identifier);
      }
      parsingAnswers = false;
      for (i = 0, len = lines.length; i < len; i++) {
        line = lines[i];
        if (!parsingAnswers) {
          if (!(answerMatch = ParsingUtils.matchAnswer(line))) {
            builder.appendToBody(line);
          } else {
            parsingAnswers = true;
            builder.addAnswer(answerMatch.content, answerMatch.correct, answerMatch.letter);
          }
        } else {
          if ((answerMatch = ParsingUtils.matchAnswer(line))) {
            builder.addAnswer(answerMatch.content, answerMatch.correct, answerMatch.letter);
          } else {
            builder.appendAnswerLine(line);
          }
        }
      }
      return builder.build();
    };

    _Class.prototype.mergeBrokenQuestions = function(questions, logFn) {
      var i, index, mergeNextOne, mergeWithNextOne, mergeWithPreviousOne, merged, msg, processedQuestion, question, questionExcerpt, ref, result, toBeMerged;
      if (logFn == null) {
        logFn = function() {};
      }
      mergeWithPreviousOne = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = questions.length; i < len; i++) {
          question = questions[i];
          results.push(question.body.trim().length === 0);
        }
        return results;
      })();
      mergeWithNextOne = mergeWithPreviousOne.slice(1);
      for (index = i = 0, ref = mergeWithNextOne.length; 0 <= ref ? i < ref : i > ref; index = 0 <= ref ? ++i : --i) {
        if (questions[index].answers.length === 0) {
          mergeWithNextOne[index] = true;
        }
      }
      mergeWithNextOne = mergeWithNextOne.concat([false]);
      result = [];
      questions = questions.slice(0);
      while (questions.length > 1) {
        processedQuestion = questions.shift();
        mergeNextOne = mergeWithNextOne.shift();
        merged = 1;
        while (mergeNextOne) {
          toBeMerged = questions.shift();
          mergeNextOne = mergeWithNextOne.shift();
          processedQuestion = QuestionMerger.merge(processedQuestion, toBeMerged);
          merged++;
        }
        result.push(processedQuestion);
        if (merged > 1) {
          processedQuestion.merged = merged;
          questionExcerpt = excerpt(processedQuestion);
          msg = "Merged " + merged + " questions: '" + questionExcerpt + "' (" + processedQuestion.answers.length + " answers total)";
          logFn(msg);
        }
      }
      return result.concat(questions);
    };

    _Class.prototype.removeInvalidQuestions = function(questions, logFn) {
      var i, len, msg, question, validQuestions;
      if (logFn == null) {
        logFn = function() {};
      }
      validQuestions = [];
      for (i = 0, len = questions.length; i < len; i++) {
        question = questions[i];
        if (!question.body.trim().length) {
          msg = "Skipped question because it has no body (" + question.answers.length + " answers)";
        } else if (question.answers.length < 2) {
          msg = "Skipped question because it has less than 2 answers: '" + (excerpt(question)) + "'";
          if (question.merged) {
            msg += " (merged from " + question.merged + " questions)";
          }
        } else if (!question.totalCorrect()) {
          msg = "Skipped question because it has no correct answers: '" + (excerpt(question)) + "'";
          if (question.merged) {
            msg += " (merged from " + question.merged + " questions)";
          }
        }
        if (msg) {
          logFn(msg);
          msg = '';
        } else {
          validQuestions.push(question);
        }
      }
      return validQuestions;
    };

    _Class.prototype.matchNonEmptyStrings = function(str) {
      return str.trim().length > 0;
    };

    return _Class;

  })());
});
