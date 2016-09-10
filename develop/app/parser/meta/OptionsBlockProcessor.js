angular.module('DrillApp').service('OptionsBlockProcessor', function(JsonLoader, SafeEvalService) {
  var parseBool, testGrader, v2mappers;
  testGrader = function(grader) {
    return SafeEvalService["eval"](grader, function(id) {
      if (id === 'total') {
        return 3;
      } else if (id === 'correct' || id === 'incorrect' || id === 'missed') {
        return 1;
      } else {
        throw new Error("Unknown variable " + id);
      }
    });
  };
  parseBool = function(v) {
    var ref;
    if (!v) {
      return false;
    } else if (v.toLowerCase && ((ref = v.toLowerCase()) === 'false' || ref === 'no' || ref === 'disabled' || ref === 'disable' || ref === '0')) {
      return false;
    } else {
      return true;
    }
  };
  v2mappers = {
    format: function(v) {
      if (!v) {
        return 'legacy';
      } else if (v === 'legacy' || v === '2' || v === '2.1') {
        return v;
      } else {
        return 'unknown';
      }
    },
    markdown: function(v) {
      v = parseBool(v);
      return {
        markdownReady: v,
        markdown: v
      };
    },
    mathjax: function(v) {
      v = parseBool(v);
      return {
        mathjaxReady: v,
        mathjax: v
      };
    },
    grading: function(v, m, logFn) {
      var e, error, matched;
      if (v === 'perQuestion' || v === 'perAnswer') {
        return {
          gradingMethod: v
        };
      }
      matched = /^custom: *(.+)$/.exec(v);
      if (matched) {
        try {
          testGrader(matched[1]);
          return {
            gradingMethod: 'custom',
            customGrader: matched[1]
          };
        } catch (error) {
          e = error;
          logFn('Custom grader caused an error while being tested');
          return {
            gradingMethod: 'perAnswer'
          };
        }
      } else {
        if (v) {
          logFn('Grader spec isn\'t recognized as a valid expression');
        }
        return {
          gradingMethod: 'perAnswer'
        };
      }
    },
    gradingRadical: function(v) {
      if (parseBool(v)) {
        return '1';
      } else {
        return '0';
      }
    },
    gradingPPQ: function(v) {
      return parseInt(v) || 1;
    },
    timeLimit: function(v) {
      var secs;
      if (v && (secs = (parseInt(v) / 5) * 5)) {
        return {
          timeLimitEnabled: true,
          timeLimitSecs: secs
        };
      } else {
        return {
          timeLimitEnabled: false,
          timeLimitSecs: 60
        };
      }
    },
    repeatIncorrect: parseBool,
    explain: function(vOrig, m, logFn) {
      var v;
      v = vOrig && vOrig.toLowerCase();
      if (v === 'summary' || v === 'optional' || v === 'always') {
        return {
          explain: v,
          showExplanations: v === 'always'
        };
      } else {
        if (vOrig) {
          logFn("Unsupported explanations mode '" + vOrig + "', falling back to 'optional'");
        }
        return {
          explain: 'optional',
          showExplanations: false
        };
      }
    },
    explanations: function(v, m, logFn) {
      var key, result, value;
      if (v === void 0) {
        return {
          explanations: {}
        };
      }
      if (!angular.isObject(v)) {
        logFn("Invalid explanations object (type: " + (typeof v) + ")");
        return {
          explanations: {}
        };
      } else if (angular.isArray(v)) {
        logFn('Invalid explanations object (type: array)');
        return {
          explanations: {}
        };
      }
      result = {};
      for (key in v) {
        value = v[key];
        if (!/^[A-Z\d\-+_]+$/i.exec(key)) {
          logFn("Invalid explanation key '" + key + "'");
        } else if (!angular.isString(value)) {
          logFn("Value of explanation '" + key + "' is not a string");
        } else if (value.trim().length === 0) {
          logFn("Value of explanation '" + key + "' is empty");
        } else {
          result[key] = value;
        }
      }
      return {
        explanations: result
      };
    }
  };
  return new ((function() {
    function _Class() {}

    _Class.prototype.process = function(str, logFn) {
      var e, error, errorType, i, len, matched, property, ref, result;
      if (logFn == null) {
        logFn = function() {};
      }
      try {
        result = new JsonLoader(v2mappers).load(str, logFn);
        ref = result.unknown;
        for (i = 0, len = ref.length; i < len; i++) {
          property = ref[i];
          logFn("Unknown option " + property);
        }
        return result.object;
      } catch (error) {
        e = error;
        matched = /[a-z\d_-]*Error/i.exec(e.toString());
        errorType = matched != null ? matched[0] : void 0;
        if (errorType === 'SyntaxError') {
          logFn('Syntax error in <options> block - parsing failed');
        } else if (errorType) {
          logFn("Parsing <options> block failed - " + errorType);
        } else {
          logFn('Parsing <options> block failed');
        }
        return new JsonLoader(v2mappers).load('{}').object;
      }
    };

    return _Class;

  })());
});
