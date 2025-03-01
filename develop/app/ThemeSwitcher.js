var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('DrillApp').service('ThemeSwitcher', function($cookies) {
  var COOKIE_NAME, getHeadLinkNodes, rebuildStyleLink, themeName;
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
    return $("link[rel" + matcher + "stylesheet][title], link[rel" + matcher + "stylesheet][data-title]");
  };
  return new ((function() {
    function _Class() {
      this.cycle = bind(this.cycle, this);
      this.switchTo = bind(this.switchTo, this);
      this.saveToCookie = bind(this.saveToCookie, this);
      this.loadFromCookie = bind(this.loadFromCookie, this);
    }

    _Class.prototype.loadFromCookie = function() {
      var current, elements, style;
      style = $cookies.get(COOKIE_NAME);
      if (!style) {
        current = getHeadLinkNodes(false).first();
        style = themeName(current);
      }
      elements = $("link[rel*=stylesheet][title='" + style + "']");
      if (elements.length === 0) {
        $cookies.remove(COOKIE_NAME);
        return;
      }
      return this.switchTo(style);
    };

    _Class.prototype.saveToCookie = function() {
      return $cookies.put(COOKIE_NAME, this.style);
    };

    _Class.prototype.getThemes = function() {
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
    };

    _Class.prototype.switchTo = function(targetTheme) {
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
    };

    _Class.prototype.cycle = function() {
      var currentIndex, nextIndex, themes;
      if (!this.style) {
        this.loadFromCookie();
      }
      themes = this.getThemes();
      currentIndex = themes.indexOf(this.style);
      nextIndex = (currentIndex + 1) % themes.length;
      this.switchTo(themes[nextIndex]);
      return this.saveToCookie();
    };

    return _Class;

  })());
});
