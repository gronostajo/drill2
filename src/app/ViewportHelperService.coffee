angular.module('DrillApp').service 'ViewportHelper', ->
  new class
    getBootstrapBreakpoint: ->
      # http://stackoverflow.com/a/19462847/1937994
      breakpointNames = ['lg', 'md', 'sm', 'xs']
      testElement = $('<div>')
      testElement.appendTo($('body'))

      for breakpoint in breakpointNames
        testElement.addClass("hidden-#{breakpoint}")
        if testElement.is(':hidden')
          return breakpoint
      return undefined

    scrollToTop: (callback) ->
      # http://stackoverflow.com/a/1145297/1937994
      if $('html').css('scrollTop') == 0 || $('body').css('scrollTop') == 0
        callback() if callback
      else
        $('html, body').animate(scrollTop: 0, 'fast', callback)
