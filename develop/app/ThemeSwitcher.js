var indexOf = [].indexOf;

angular.module('DrillApp').service('ThemeSwitcher', function($cookies) {
  var COOKIE_NAME, getHeadLinkNodes, rebuildStyleLink, themeName;
  // This file intentionally uses jQuery, not angular.element, because it uses
  // more powerful selectors that aren't supported by angular.element.
  COOKIE_NAME = 'stylesheet';
  themeName = function(e) {
    return e.attr('data-title') || e.attr('title');
  };
  rebuildStyleLink = function(e, rel) {
    var node;
    node = $('<link>');
    node.attr('href', e.attr('href'));
    node.attr('data-title', themeName(e));
    node.attr('rel', rel);
    return node;
  };
  getHeadLinkNodes = function(includeAlternate) {
    var matcher;
    matcher = includeAlternate ? '*=' : '=';
    return $(`link[rel${matcher}stylesheet][title], link[rel${matcher}stylesheet][data-title]`);
  };
  return new (class {
    constructor() {
      this.loadFromCookie = this.loadFromCookie.bind(this);
      this.saveToCookie = this.saveToCookie.bind(this);
      this.switchTo = this.switchTo.bind(this);
      this.cycle = this.cycle.bind(this);
    }

    loadFromCookie() {
      var current, elements, style;
      style = $cookies.get(COOKIE_NAME);
      if (!style) {
        current = getHeadLinkNodes(false).first();
        style = themeName(current);
      }
      elements = $(`link[rel*=stylesheet][title='${style}']`);
      if (elements.length === 0) {
        $cookies.remove(COOKIE_NAME);
        return;
      }
      return this.switchTo(style);
    }

    saveToCookie() {
      return $cookies.put(COOKIE_NAME, this.style);
    }

    getThemes() {
      var head, linkNodes, themeNames;
      head = $('head');
      linkNodes = getHeadLinkNodes(true);
      themeNames = [];
      linkNodes.each(function() {
        var name, node;
        node = $(this);
        name = themeName(node);
        if (indexOf.call(themeNames, name) < 0) {
          return themeNames.push(name);
        }
      });
      return themeNames;
    }

    switchTo(targetTheme) {
      var linkNodes, rebuiltLinks;
      if (this.style === targetTheme) {
        return;
      }
      this.style = targetTheme;
      linkNodes = getHeadLinkNodes(true);
      rebuiltLinks = [];
      linkNodes.each(function() {
        var linkElement, newRel, rebuilt;
        linkElement = $(this);
        newRel = themeName(linkElement) === targetTheme ? 'stylesheet' : 'alternate stylesheet';
        rebuilt = rebuildStyleLink(linkElement, newRel);
        return rebuiltLinks.push(rebuilt);
      });
      linkNodes.remove();
      return $('head').append(rebuiltLinks);
    }

    cycle() {
      var currentIndex, nextIndex, themes;
      if (!this.style) {
        this.loadFromCookie();
      }
      themes = this.getThemes();
      currentIndex = themes.indexOf(this.style);
      nextIndex = (currentIndex + 1) % themes.length;
      this.switchTo(themes[nextIndex]);
      return this.saveToCookie();
    }

  })();
});
