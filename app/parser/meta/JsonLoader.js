angular.module('DrillApp').service('JsonLoader', function() {
  var JsonLoader;
  return JsonLoader = class JsonLoader {
    constructor(mappers) {
      this.mappers = mappers;
    }

    load(json, logFn = function() {}) {
      var e, input, mappedValue, mappingFn, member, output, ref, unknown, value, valueMember;
      input = JSON.parse(json);
      output = {};
      ref = this.mappers;
      for (member in ref) {
        mappingFn = ref[member];
        try {
          mappedValue = mappingFn(input[member], member, logFn);
        } catch (error) {
          e = error;
          logFn(`Mapper ${member} threw an exception`);
          continue;
        }
        if (!angular.isObject(mappedValue)) {
          output[member] = mappedValue;
        } else {
          for (valueMember in mappedValue) {
            value = mappedValue[valueMember];
            if (valueMember in output) {
              throw new Error(`Member ${valueMember} already exists`);
            }
            output[valueMember] = value;
          }
        }
      }
      unknown = (function() {
        var results;
        results = [];
        for (member in input) {
          if (!(member in this.mappers)) {
            results.push(member);
          }
        }
        return results;
      }).call(this);
      return {
        object: output,
        unknown: unknown
      };
    }

  };
});
