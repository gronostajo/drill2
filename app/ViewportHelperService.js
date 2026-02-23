angular.module('DrillApp').service('ViewportHelper', function() {
  return new (class {
    getBootstrapBreakpoint() {
      var breakpoint, breakpointNames, i, len, testElement;
      // http://stackoverflow.com/a/19462847/1937994
      breakpointNames = ['lg', 'md', 'sm', 'xs'];
      testElement = $('<div>');
      testElement.appendTo($('body'));
      for (i = 0, len = breakpointNames.length; i < len; i++) {
        breakpoint = breakpointNames[i];
        testElement.addClass(`hidden-${breakpoint}`);
        if (testElement.is(':hidden')) {
          return breakpoint;
        }
      }
      return void 0;
    }

    scrollToTop(callback) {
      // http://stackoverflow.com/a/1145297/1937994
      if ($('html').css('scrollTop') === 0 || $('body').css('scrollTop') === 0) {
        if (callback) {
          return callback();
        }
      } else {
        return $('html, body').animate({
          scrollTop: 0
        }, 'fast', callback);
      }
    }

  })();
});
