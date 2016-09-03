angular.module('DrillApp').service 'QuestionParsingUtils', (ParsingUtils, QuestionBuilder, QuestionMerger) ->
  excerpt = (question, limit = 40) ->
    body = question.body.trim()
    if body.length > limit
      body.substring(0, limit) + '...'
    else if body.length is 0
      '[no body]'
    else
      body

  new class
    parseQuestion: (str) ->
      lines = ParsingUtils.splitWithNewlines(str)
      builder = new QuestionBuilder()

      if (identifierMatched = ParsingUtils.matchIdentifier(lines[0]))
        lines = lines[1..]
        builder.appendToBody(identifierMatched.content)
        builder.setIdentifier(identifierMatched.identifier)

      parsingAnswers = no

      for line in lines
        if not parsingAnswers
          if not (answerMatch = ParsingUtils.matchAnswer(line))
            builder.appendToBody(line)
          else
            parsingAnswers = yes
            builder.addAnswer(answerMatch.content, answerMatch.correct, answerMatch.letter)
        else
          if (answerMatch = ParsingUtils.matchAnswer(line))
            builder.addAnswer(answerMatch.content, answerMatch.correct, answerMatch.letter)
          else
            builder.appendAnswerLine(line)

      builder.build()

    mergeBrokenQuestions: (questions, logFn = ->) ->
      mergeWithPreviousOne = (question.body.trim().length is 0 for question in questions)
      mergeWithNextOne = mergeWithPreviousOne[1..]  # one 'no' missing for last question
      for index in [0...mergeWithNextOne.length] when questions[index].answers.length is 0
        mergeWithNextOne[index] = yes
      mergeWithNextOne = mergeWithNextOne.concat([no])

      result = []
      questions = questions[..]
      while questions.length > 1
        processedQuestion = questions.shift()
        mergeNextOne = mergeWithNextOne.shift()
        merged = 1
        while mergeNextOne
          toBeMerged = questions.shift()
          mergeNextOne = mergeWithNextOne.shift()
          processedQuestion = QuestionMerger.merge(processedQuestion, toBeMerged)
          merged++
        result.push(processedQuestion)
        if merged > 1
          processedQuestion.merged = merged
          questionExcerpt = excerpt(processedQuestion)
          msg = "Merged #{merged} questions: '#{questionExcerpt}' (#{processedQuestion.answers.length} answers total)"
          logFn(msg)

      result.concat(questions)

    removeInvalidQuestions: (questions, logFn = ->) ->
      validQuestions = []

      for question in questions
        if not question.body.trim().length
          msg = "Skipped question because it has no body (#{question.answers.length} answers)"
        else if question.answers.length < 2
          msg = "Skipped question because it has less than 2 answers: '#{excerpt(question)}'"
          if question.merged
            msg += " (merged from #{question.merged} questions)"
        else if not question.totalCorrect()
          msg = "Skipped question because it has no correct answers: '#{excerpt(question)}'"
          if question.merged
            msg += " (merged from #{question.merged} questions)"

        if msg
          logFn(msg)
          msg = ''
        else
          validQuestions.push(question)

      validQuestions

    matchNonEmptyStrings: (str) ->
      str.trim().length > 0
