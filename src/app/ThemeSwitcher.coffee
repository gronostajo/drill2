angular.module('DrillApp').service 'ThemeSwitcher', ($cookies) ->
# This file intentionally uses jQuery, not angular.element, because it uses
# more powerful selectors that aren't supported by angular.element.

  COOKIE_NAME = 'stylesheet'

  themeName = (e) ->
    e.attr('data-title') || e.attr('title')

  rebuildStyleLink = (e, rel) ->
    node = $('<link>')
    node.attr('href', e.attr('href'))
    node.attr('data-title', themeName(e))
    node.attr('rel', rel)
    node

  getHeadLinkNodes = (includeAlternate) ->
    matcher = if includeAlternate then '*=' else '='
    $("link[rel#{matcher}stylesheet][title], link[rel#{matcher}stylesheet][data-title]")

  new class
    loadFromCookie: =>
      style = $cookies.get(COOKIE_NAME)
      if not style
        current = getHeadLinkNodes(false).first()
        style = themeName(current)

      elements = $("link[rel*=stylesheet][title='#{style}']")
      if elements.length == 0
        $cookies.remove(COOKIE_NAME)
        return

      @switchTo(style)

    saveToCookie: =>
      $cookies.put(COOKIE_NAME, @style)

    getThemes: ->
      head = $('head')
      linkNodes = getHeadLinkNodes(true)

      themeNames = []
      linkNodes.each ->
        node = $(this)
        name = themeName(node)
        if name not in themeNames
          themeNames.push(name)

      themeNames

    switchTo: (targetTheme) =>
      return if @style == targetTheme
      @style = targetTheme

      linkNodes = getHeadLinkNodes(true)

      rebuiltLinks = []
      linkNodes.each ->
        linkElement = $(this)
        newRel = if themeName(linkElement) == targetTheme then 'stylesheet' else 'alternate stylesheet'
        rebuilt = rebuildStyleLink(linkElement, newRel)
        rebuiltLinks.push(rebuilt)

      linkNodes.remove()
      $('head').append(rebuiltLinks)

    cycle: =>
      if not @style
        @loadFromCookie()

      themes = @getThemes()
      currentIndex = themes.indexOf(@style)
      nextIndex = (currentIndex + 1) % themes.length
      @switchTo(themes[nextIndex])
      @saveToCookie()
