angular.module('DrillApp').service 'OptionsBlockProcessor', (JsonLoader, SafeEvalService) ->
  testGrader = (grader) ->
    SafeEvalService.eval grader, (id) ->
      if id is 'total'
        3
      else if id in ['correct', 'incorrect', 'missed']
        1
      else throw new Error("Unknown variable #{id}")

  parseBool = (v) ->
    if not v
      return false
    else if v.toLowerCase and v.toLowerCase() in ['false', 'no', 'disabled', 'disable', '0']
      return false
    else
      return true

  v2mappers =
    format: (v) ->
      if not v
        'legacy'
      else if v in ['legacy', '2', '2.1']
        v
      else 'unknown'

    markdown: (v) ->
      v = parseBool(v)
      markdownReady: v
      markdown: v

    mathjax: (v) ->
      v = parseBool(v)
      mathjaxReady: v
      mathjax: v

    grading: (v, m, logFn) ->
      if v in ['perQuestion', 'perAnswer']
        return gradingMethod: v
      matched = /^custom: *(.+)$/.exec(v)
      if matched
        try
          testGrader(matched[1])
          return {gradingMethod: 'custom', customGrader: matched[1]}
        catch e
          logFn('Custom grader caused an error while being tested')
          return gradingMethod: 'perAnswer'
      else
        logFn('Grader spec isn\'t recognized as a valid expression') if v
        return gradingMethod: 'perAnswer'

    gradingRadical: (v) ->
      if parseBool(v) then '1' else '0'

    gradingPPQ: (v) ->
      parseInt(v) or 1

    timeLimit: (v) ->
      if v and (secs = (parseInt(v) / 5) * 5)
        timeLimitEnabled: yes
        timeLimitSecs: secs
      else
        timeLimitEnabled: no
        timeLimitSecs: 60

    repeatIncorrect: parseBool

    explain: (vOrig, m, logFn) ->
      v = vOrig and vOrig.toLowerCase()
      if v in ['summary', 'optional', 'always']
        explain: v
        showExplanations: v is 'always'
      else
        logFn("Unsupported explanations mode '#{vOrig}', falling back to 'optional'") if vOrig
        explain: 'optional'
        showExplanations: no

    explanations: (v, m, logFn) ->
      return explanations: {} if v is undefined
      if not angular.isObject(v)
        logFn("Invalid explanations object (type: #{typeof v})")
        return explanations: {}
      else if angular.isArray(v)
        logFn('Invalid explanations object (type: array)')
        return explanations: {}
      result = {}
      for key, value of v
        if not /^[A-Z\d\-+_]+$/i.exec(key)
          logFn("Invalid explanation key '#{key}'")
        else if not angular.isString(value)
          logFn("Value of explanation '#{key}' is not a string")
        else if value.trim().length is 0
          logFn("Value of explanation '#{key}' is empty")
        else
          result[key] = value
      explanations: result

  new class
    process: (str, logFn = ->) ->
      try
        result = new JsonLoader(v2mappers).load(str, logFn)
        logFn("Unknown option #{property}") for property in result.unknown
        result.object
      catch e
        matched = /[a-z\d_-]*Error/i.exec(e.toString())
        errorType = matched?[0]
        if errorType is 'SyntaxError'
          logFn('Syntax error in <options> block - parsing failed')
        else if errorType
          logFn("Parsing <options> block failed - #{errorType}")
        else
          logFn('Parsing <options> block failed')
        new JsonLoader(v2mappers).load('{}').object
