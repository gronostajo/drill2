angular.module('DrillApp').service 'JsonLoader', ->
  class JsonLoader
    constructor: (@mappers) ->

    load: (json, logFn = ->) ->
      input = JSON.parse(json)
      output = {}

      for member, mappingFn of @mappers
        try
          mappedValue = mappingFn(input[member], member, logFn)
        catch e
          logFn("Mapper #{member} threw an exception")
          continue
        if not angular.isObject(mappedValue)
          output[member] = mappedValue
        else
          for valueMember, value of mappedValue
            throw new Error("Member #{valueMember} already exists") if valueMember of output
            output[valueMember] = value
      unknown = (member for member of input when not (member of @mappers))

      object: output
      unknown: unknown
