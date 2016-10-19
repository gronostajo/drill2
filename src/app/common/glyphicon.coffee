angular.module('DrillApp').directive 'glyphicon', ->
  restrict: 'E'
  replace: yes
  template: '<i class="glyphicon"></i>'
  link: (scope, element, attr) ->
    attr.$observe 'icon', (newValue, oldValue) ->
      element.removeClass("glyphicon-#{oldValue}") if oldValue
      element.addClass("glyphicon-#{newValue}") if newValue
