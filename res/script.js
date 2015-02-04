/*
 *	Drill 2 scripts
 *	https://github.com/gronostajo/drill2
 */


// Fisher-Yates shuffling algorithm
// Adapted from: http://bost.ocks.org/mike/shuffle/

function shuffle(input) {
	var arr = input.slice(0);	// shallow copy
	var numToShuffle = arr.length;

	while (numToShuffle) {
		var pick = Math.floor(Math.random() * numToShuffle);
		numToShuffle--;

		var temp = arr[numToShuffle];
		arr[numToShuffle] = arr[pick];
		arr[pick] = temp;
	}

	return arr;
}


// Detect current Bootstrap breakpoint
// Adapted from: http://stackoverflow.com/a/19462847/1937994

function bootstrapBreakpoint() {
	var envValues = ["xs", "sm", "md", "lg"];

	var el = $('<div>');
	el.appendTo($('body'));

	for (var i = envValues.length - 1; i >= 0; i--) {
		var envVal = envValues[i];

		el.addClass('hidden-'+envVal);
		if (el.is(':hidden')) {
			el.remove();
			return envVal
		}
	}
}



// Scroll to top with animation
// Based on: http://stackoverflow.com/a/1145297/1937994

function scrollToTop(callback) {
    if ($('html').css('scrollTop') == 0 || $('body').css('scrollTop') == 0) {
        if (callback) callback();
    }
    else {
        $('html, body').animate({ scrollTop: 0 }, 'fast', callback);
    }
}


// on DOM ready

$(function() {

	// read and set last stats panel state
	var statsPreference = $.cookie('stats');
	if (!statsPreference) {
		var initialBreakpoint = bootstrapBreakpoint();
		statsPreference = (initialBreakpoint == 'xs') ? 'collapsed' : 'expanded';
	}

    var $collapseScore = $('#collapseScore');

    if (statsPreference == 'expanded') {
		$collapseScore.collapse('show');
		$.cookie('stats', 'expanded');
		$('#collapseScoreToggle').removeClass('collapsed');
	}
	else {
		$.cookie('stats', 'collapsed');
		$('#collapseScoreToggle').addClass('collapsed');
	}

	// hook collapse and expand events to update cookie
	$collapseScore
        .on('show.bs.collapse', function () {
		    $.cookie('stats', 'expanded');
	    })
        .on('hide.bs.collapse', function () {
		    $.cookie('stats', 'collapsed');
	    });
});
