angular.module('DrillApp').service('QuestionParsingUtils', function(ParsingUtils, QuestionBuilder) {
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
        builder.appendBodyLine(identifierMatched.content);
        builder.setIdentifier(identifierMatched.identifier);
      }
      parsingAnswers = false;
      for (i = 0, len = lines.length; i < len; i++) {
        line = lines[i];
        if (!parsingAnswers) {
          if (!(answerMatch = ParsingUtils.matchAnswer(line))) {
            builder.appendBodyLine(line);
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
      var mergeNextOne, mergeWithNextOne, mergeWithPreviousOne, merged, msg, processedQuestion, question, questionExcerpt, questionsCopy, result, toBeMerged;
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
      mergeWithNextOne = mergeWithPreviousOne.slice(1).concat([false]);
      result = [];
      questionsCopy = questions.slice(0);
      while (questionsCopy.length > 1) {
        processedQuestion = questionsCopy.shift();
        mergeNextOne = mergeWithNextOne.shift();
        merged = 1;
        while (mergeNextOne) {
          toBeMerged = questionsCopy.shift();
          mergeNextOne = mergeWithNextOne.shift();
          processedQuestion.answers = processedQuestion.answers.concat(toBeMerged.answers);
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
      return result.concat(questionsCopy);
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

    return _Class;

  })());
});
