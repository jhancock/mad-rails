// based on: http://www.digitalinferno.net/blog/jquery-plugin-tinytips-1-1/ 

(function($){  
	$.fn.myTips = function (options) {
		var position = options['position'] || 'right';
		var width = options['width'] || 360;
		var tipName = 'myTip';
		var contentClass = tipName + 'Content';
		var contentBottomClass = contentClass + 'Bottom'
		
		/* User settings
		**********************************/
		
		// Enter the markup for your tooltips here. The wrapping div must have a class of tinyTip and 
		// it must have a div with the class "content" somewhere inside of it.
		var tipFrame = '<div class="' + tipName + '"><div class="' + contentClass + '"></div><div class="' + contentBottomClass + '"><p>HELLO</p></div></div>';
		
		// Speed of the animations in milliseconds - 1000 = 1 second.
		var animSpeed = 300;
		
		/***************************************************************************************************/
		/* End of user settings - Do not edit below this line unless you are trying to edit functionality. */
		/***************************************************************************************************/
		
		// Global tinyTip variables;
		var tinyTip;
		var tText;
		
		// When we hover over the element that we want the tooltip applied to
		$(this).hover(function() {
	
			// Inject the markup for the tooltip into the page and
			// set the tooltip global to the current markup and then hide it.
			$('body').append(tipFrame);
			var divTip = 'div.'+tipName;
			tinyTip = $(divTip);
			tinyTip.width(width);
			tinyTip.hide();
			
			// Grab the content for the tooltip from the title, rel, and tags attributes and
			// inject it into the markup for the current tooltip. 
			title = $(this).attr('title') || "";
			rel = $(this).attr('data-summary') || "";
			var tipCont = '<b>' + title + '</b><br />' + rel;
			$(divTip + ' .' + contentClass).html(tipCont);
			tag_names = $(this).attr('data-tags') || "	";
			if (tag_names.length > 0) {
				tag_names = '<b>' + tag_names + '  - </b>';
			} else {
				tag_names = "";
			}
			$(divTip + ' .' + contentBottomClass).html(tag_names + '<b>' + $(this).attr('data-chars') + ' 字数</b>');
			tText = $(this).attr('title');
			$(this).attr('title', '');
			
			// Grab the coordinates for the element with the tooltip and make a new copy
			// so that we can keep the original un-touched.
			viewport_height = $(window).height();
			var pos = $(this).offset();
			var nPos = pos;
			if ((viewport_height / 3) > pos.top) {
				// top third of viewport
				var yOffset = 40;
			} else {
				if (pos.top > (2 * (viewport_height / 3))) {
					// bottom third of viewport
					var yOffset = 200;
				} else {
					// middle third of viewport
					var yOffset = 100;
				}
			}
			
			if (position == 'right') {
	 			// Offsets so that the tooltip is centered over the element it is being applied to but
				// raise it up above the element so it isn't covering it.
				var xOffset = $(this).width() + 15;			
				// Add the offsets to the tooltip position
				nPos.top = pos.top - yOffset;
				nPos.left = pos.left + xOffset;
			} else {
				if (position == 'left') {
					var xOffset = tinyTip.width() + 15;			
					nPos.top = pos.top - yOffset;
					nPos.left = pos.left - xOffset;
				}
			}
			
			// Make sure that the tooltip has absolute positioning and a high z-index, 
			// then place it at the correct spot and fade it in.
			tinyTip.css('position', 'absolute').css('z-index', '1000');
			tinyTip.css(nPos).fadeIn(animSpeed);
			
		}, function() {
			
			$(this).attr('title', tText);
		
			// Fade the tooltip out once the mouse moves away and then remove it from the DOM.
			tinyTip.fadeOut(animSpeed, function() {
				$(this).remove();
			});
			
		});
		
	}

})(jQuery);
