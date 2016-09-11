angular.module('DrillApp').service 'OptionsBlockUtils', (OptionsBlockProcessor) ->
  optionsBlockRegex = /<options>\s*(\{(?:.|\n|\r)*})\s*/i

  new class
    loadOptions: (target) ->
      (parts, logFn) ->
        if not angular.isArray(parts)
          throw new Error('Expected an array as input')
        if not angular.isObject(target)
          throw new Error('Expected an object as target')
        return parts if parts.length is 0

        lastPart = parts[parts.length - 1]
        if not (matched = optionsBlockRegex.exec(lastPart))
          defaults = OptionsBlockProcessor.process('{}')
          angular.extend(target, defaults)
          return parts

        optionsString = matched[1]
        options = OptionsBlockProcessor.process(optionsString, logFn)
        angular.extend(target, options)
        parts.slice(0, parts.length - 1)

    assignExplanations: (options) ->
      explanations = options.explanations
      (questions, logFn) ->
        if not angular.isArray(questions)
          throw new Error('Expected an array of questions')
        if not angular.isObject(explanations)
          throw new Error('Expected a map of explanations')
        return questions if questions.length is 0

        loadedIds = (id for id of explanations)
        commonIds = []
        for question in questions when question.id of explanations
          question.loadExplanation(explanations)
          commonIds.push(question.id)

        if loadedIds.length > commonIds.length
          logFn("#{loadedIds.length - commonIds.length} explanations couldn't be matched to questions")

        options.explanationsAvailable = (commonIds.length > 0)
        questions
