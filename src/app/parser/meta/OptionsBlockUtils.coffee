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

    assignQuestionExtras: (options) ->
      explanations = options.explanations
      relatedLinks = options.relatedLinks
      (questions, logFn) ->
        if not angular.isArray(questions)
          throw new Error('Expected an array of questions')
        if not angular.isObject(explanations)
          throw new Error('Expected a map of explanations')
        if not angular.isObject(relatedLinks)
          throw new Error('Expected a map of related links')
        return questions if questions.length is 0

        loadedIds = (id for id of explanations)
        commonExplanationIds = []
        for question in questions when question.id of explanations
          question.setExplanation(explanations[question.id])
          commonExplanationIds.push(question.id)

        if loadedIds.length > commonExplanationIds.length
          logFn("#{loadedIds.length - commonExplanationIds.length} explanations couldn't be matched to questions")

        loadedIds = (id for id of relatedLinks)
        commonLinkIds = []
        for question in questions when question.id of relatedLinks
          question.setRelatedLinks(relatedLinks[question.id])
          commonLinkIds.push(question.id)

        if loadedIds.length > commonLinkIds.length
          logFn("#{loadedIds.length - commonLinkIds.length} related links couldn't be matched to questions")

        options.explanationsAvailable = (commonExplanationIds.length > 0)
        questions
