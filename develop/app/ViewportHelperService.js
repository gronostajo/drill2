angular.module('DrillApp').service('ViewportHelper', function() {
  return new ((function() {
    function _Class() {}

    _Class.prototype.getBootstrapBreakpoint = function() {
      var breakpoint, breakpointNames, i, len, testElement;
      breakpointNames = ['lg', 'md', 'sm', 'xs'];
      testElement = $('<div>');
      testElement.appendTo($('body'));
      for (i = 0, len = breakpointNames.length; i < len; i++) {
        breakpoint = breakpointNames[i];
        testElement.addClass("hidden-" + breakpoint);
        if (testElement.is(':hidden')) {
          return breakpoint;
        }
      }
      return void 0;
    };

    _Class.prototype.scrollToTop = function(callback) {
      if ($('html').css('scrollTop') === 0 || $('body').css('scrollTop') === 0) {
        if (callback) {
          return callback();
        }
      } else {
        return $('html, body').animate({
          scrollTop: 0
        }, 'fast', callback);
      }
    };

    return _Class;

  })());
});
