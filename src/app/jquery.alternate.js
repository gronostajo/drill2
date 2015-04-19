(function($) {

	function getCurrent() {
		var current = $('link[rel=stylesheet]').filter('[title], [data-title]').first();
		var dt = current.attr('data-title');
		return dt ? dt : current.attr('title');
	}

	function getSets(e) {
		var nodes = e.find('link[rel*=stylesheet]').filter('[title], [data-title]');

		var sets = $.map(nodes, function(e) {
			e = $(e);
			var dt = e.attr('data-title');
			return dt ? dt : e.attr('title');
		});

		// http://stackoverflow.com/a/14438954/1937994
		function onlyUnique(value, index, self) {
			return self.indexOf(value) === index;
		}

		sets = sets.filter(onlyUnique);

		// move current styleset to the front:
		var current = getCurrent();
		var pos = sets.indexOf(current);
		sets.splice(pos, 1);
		sets.unshift(current);

		return sets;
	}

	function rebuildStyleLink(e, rel) {
		var n = $('<link/>');
		var dt = e.attr('data-title');

		n.attr('href', e.attr('href'));
		n.attr('data-title', dt ? dt : e.attr('title'));
		n.attr('rel', rel);

		return n;
	}

	function savePreference(pref) {
		if (!$.cookie) return;

		$.cookie('stylesheet', pref);
	}

	function restorePreference() {
		if (!$.cookie) return;

		var pref = $.cookie('stylesheet');
		if (!pref) return;

		var sel = $("link[rel*=stylesheet][title='" + pref + "']");
		if (sel.length == 0) {
			if ($.removeCookie) $.removeCookie('stylesheet');
			return;
		}
		$.alternate(pref);
	}

	$['alternate'] = function(switchTo) {
		//noinspection JSJQueryEfficiency
		var head = $('head');

		if (typeof(switchTo) == 'undefined') {
			return getSets(head);
		}

		else if (switchTo == '-') {
			restorePreference();
			return;
		}

		else if (getCurrent() == switchTo) {
			return;
		}

		var linkNodes = head.find('link[rel*=stylesheet]');
		linkNodes = linkNodes.filter('[title], [data-title]');

		var rebuilt = [];

		linkNodes.filter("link[rel='stylesheet']").each(function () {
			rebuilt.push(rebuildStyleLink($(this), 'alternate stylesheet'));
		});
		linkNodes.filter("[title='" + switchTo + "'], [data-title='" + switchTo + "']").each(function () {
			rebuilt.push(rebuildStyleLink($(this), 'stylesheet'));
		});

		linkNodes.remove();
		head.append(rebuilt);

		//// fails in Firefox:
		//setTimeout(function () {
		//	var stamp = (new Date()).getTime();
		//	$(rebuilt).each(function () {
		//		var n = $(this);
		//		n.attr('title', n.attr('data-title') + ' //' + stamp);
		//	});
		//}, 10);

		savePreference(switchTo);
	};

})(jQuery);