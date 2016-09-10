angular.module('DrillApp').filter('decPlaces', function() {
  return function(x, dec) {
    var pow;
    pow = Math.pow(10, dec);
    return (Math.round(x * pow)) / pow;
  };
}).filter('markdown', function($sce) {
  return function(str, $scope) {
    var ast, fix, html, parser, renderer;
    if (!(str && $scope.config.markdown)) {
      return '';
    }
    parser = new commonmark.Parser();
    renderer = new commonmark.HtmlRenderer();
    ast = parser.parse(str);
    fix = function(node) {
      var i, j, ref, split, wanted;
      if (node._type === 'CodeBlock') {
        str = node._literal;
        if (node._isFenced) {
          str = str.substring(1, str.length - 1);
        }
        split = str.split('\n');
        wanted = [];
        for (i = j = 0, ref = split.length; j < ref; i = j += 2) {
          wanted.push(split[i]);
        }
        node._literal = wanted.join('\n');
      } else {
        if (node._firstChild) {
          fix(node._firstChild);
        }
        if (node._next) {
          fix(node._next);
        }
      }
    };
    fix(ast);
    html = renderer.render(ast);
    return $sce.trustAsHtml(html);
  };
}).filter('lines', function() {
  return function(str) {
    if (str) {
      return str.split(/\s*(?:\r?\n)(?:\r?\n\s)*/);
    } else {
      return [];
    }
  };
}).filter('doubleNewlines', function() {
  return function(str) {
    if (str) {
      return str.replace(/\n+/g, '\n\n');
    } else {
      return '';
    }
  };
}).filter('minutes', function() {
  return function(secs) {
    var mins;
    if (!secs) {
      return '';
    }
    secs = parseInt(secs);
    mins = Math.floor(secs / 60);
    secs = (secs % 60).toString();
    while (secs.length < 2) {
      secs = '0' + secs;
    }
    return mins + ":" + secs;
  };
}).filter('minsSecs', function() {
  return function(secs) {
    var mins, mstr;
    mins = Math.floor(secs / 60);
    mstr = mins > 0 ? mins + 'm ' : '';
    return mstr + (secs % 60) + 's';
  };
}).filter('scoreFormat', function(decPlacesFilter, minsSecsFilter) {
  return function(score, limitedTime, timeLimit) {
    var score_, str, total;
    score_ = decPlacesFilter(score.score, 2);
    total = decPlacesFilter(score.total, 2);
    str = score_ + " / " + total + " pts";
    if (limitedTime) {
      str += ', ' + minsSecsFilter(timeLimit - score.timeLeft);
    }
    return str;
  };
}).filter('no', function() {
  return function(x, capitalized) {
    return x != null ? x : capitalized ? 'No' : 'no';
  };
}).filter('averageTime', function() {
  return function(questions, timeLimit) {
    var count, j, k, len, len1, log, question, ref, total;
    count = 0;
    total = 0;
    for (j = 0, len = questions.length; j < len; j++) {
      question = questions[j];
      count += question.scoreLog.length;
      ref = question.scoreLog;
      for (k = 0, len1 = ref.length; k < len1; k++) {
        log = ref[k];
        total += timeLimit - log.timeLeft;
      }
    }
    return Math.round(total / count);
  };
}).filter('shuffle', function() {
  return function(input) {
    var arr, pick, pivot, ref;
    arr = input.slice(0);
    pivot = arr.length;
    if (pivot <= 1) {
      return arr;
    }
    while (--pivot) {
      pick = Math.floor(Math.random() * (pivot + 1));
      ref = [arr[pick], arr[pivot]], arr[pivot] = ref[0], arr[pick] = ref[1];
    }
    return arr;
  };
}).filter('percentageOf', function() {
  return function(fraction, total) {
    if (total !== 0) {
      return Math.round(fraction * 100 / total) + '%';
    } else {
      return '0%';
    }
  };
}).filter('bankersPercentageOf', function() {
  return function(fraction, total) {
    var delta, epsilon, num, numFloor, rounded, truncatedNum;
    if (total !== 0) {
      num = fraction * 100 / total;
      truncatedNum = num.toFixed(8);
      numFloor = Math.floor(truncatedNum);
      delta = truncatedNum - numFloor;
      epsilon = 1e-8;
      rounded = delta > 0.5 - epsilon && delta < 0.5 + epsilon ? numFloor % 2 === 0 ? numFloor : numFloor + 1 : Math.round(truncatedNum);
      return rounded + '%';
    } else {
      return '0%';
    }
  };
});
