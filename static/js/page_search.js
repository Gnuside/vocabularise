var COLOR_EXPECTED = [ 60, 165, 43 ], // #3ca52b
	COLOR_CONTROVERSIAL = [ 231, 80, 24 ], // #e75018
	COLOR_AGGREGATING= [ 0, 139, 208 ], // #008bd0
	COLOR_BLACK = [0,0,0],
	TEXTSIZE_MIN = 0.6,
	TEXTSIZE_MAX = 2,
	AJAX_TIMEOUT = 8000,
	SLIDE_DELTA = 30,
	TAG_LIST_MAX_HEIGHT = 300;

function reverse_list ( list_header ) {
	var tag_class = get_tag_class( $(list_header).parent("div.tag") ), ul, lis, factor, res_size;
	switch ( tag_class ) {
		case "expected" :
			ul = $("#list_expected");
			break;
		case "controversial" :
			ul = $("#list_controversial");
			break;
		case "aggregating" :
			ul = $("#list_aggregating");
			break;
		default :
			return;
			break;
	}
	ul.fadeOut("normal", function () {
		lis = ul.children("li").detach().get();
		lis.reverse();
		$(lis).appendTo( ul ).each(function (index) {
			factor = index / lis.length;
			res_size = TEXTSIZE_MAX - ( factor * (TEXTSIZE_MAX - TEXTSIZE_MIN));
			$(this).children("a").css("font-size", res_size + "em");
		});
		$(this).fadeIn("slow");
	});
}

function attach_fancybox ( li, tag_class, li_color ) {
	li.fancybox({
		autoScale: true,
		autoDimensions: true,
		width: 950,
		centerOnScroll: true,
		content: '<div id="tag_details"><img src="/images/ajax-loader-bar.gif" alt="" width="220" height="19" /></div>',
		hideOnOverlayClick: true,
		overlayColor: "#ffffff",
		scrolling: "no",
		showCloseButton: false,
		titleShow: false,
		onComplete: function (curArr, curIdx, curOpts) {
			var view = [
				$(window).width() - (curOpts.margin * 2),
				$(window).height() - (curOpts.margin * 2),
				$(document).scrollLeft() + curOpts.margin,
				$(document).scrollTop() + curOpts.margin
			],
			tag = $(curArr).data("tag"),
			data = [
				'<div class="col_content span-24 last">',
					'<div class="tag_expected span-8">',
						get_tag_data( curArr, tag, li_color, COLOR_EXPECTED, tag_class, "expected" ),
					'</div>',
					'<div class="tag_controversial span-8">',
						get_tag_data( curArr, tag, li_color, COLOR_CONTROVERSIAL, tag_class, "controversial" ),
					'</div>',
					'<div class="tag_aggregating span-8 last">',
						get_tag_data( curArr, tag, li_color, COLOR_AGGREGATING, tag_class, "aggregating" ),
					'</div>',
				'</div>'
			];
			$("#fancybox-wrap").fadeOut( "slow", function () {
				$("#fancybox-content").css({
					width: 950
				});
				$("#fancybox-wrap").css({
					width: 970,
					top: parseInt(Math.max(view[3] - 20, view[3] + ((view[1] - $("#fancybox-content").height() - 40) * 0.5) - curOpts.padding)), // @see fancybox center
					left: parseInt(Math.max(view[2] - 20, view[2] + ((view[0] - 950 - 40) * 0.5) - curOpts.padding)) // @see fancybox center
				});
				$("#tag_details").html( data.join("") );
			}).fadeIn( "slow" );
		}
	});
}

function get_tag_data ( liElement, tag, li_color, color, tag_class, type ) {
	var data = [], links, lisElements = $("div.tag_" + type + " > ul.taglist").children(),
		rank = 0, tagLisElements, typeLisElements, tagRank = 0, factor, res_rgb;
	// find rank
	lisElements.each( function ( index ) {
		if ( tag === $(this).data("tag") ) {
			rank = index + 1;
			return false;
		}
	});
	// tag not in list
	if ( 0 === rank ) {
		return "<p>Not in list</p>";
	}
	// tag name or arrows
	if ( tag_class === type ) {
		data.push( '<h3 style="color: rgb(' + li_color[0] + ',' + li_color[1] + ',' + li_color[2] + ');">' + tag + "</h3>" );
		links = $(liElement).data( "links" );
	} else {
		tagLisElements = $("div.tag_" + tag_class + " > ul.taglist").children();
		typeLisElements = $("div.tag_" + type + " > ul.taglist").children();
		// search rank in clicked list
		tagLisElements.each( function (index) {
			if ( tag === $(this).data("tag") ) {
				tagRank = index + 1;
				return false;
			}
		});
		// search links
		typeLisElements.each( function () {
			if ( tag === $(this).data("tag") ) {
				links = $(this).data("links");
				return false;
			}
		});
		if ( rank > tagRank ) {
			data.push( '<img src="/images/bottom-arrow-' + type + '-tiny.png" alt="" width="27" height="12" />' );
		} else if ( rank < tagRank ) {
			data.push( '<img src="/images/top-arrow-' + type + '-tiny.png" alt="" width="27" height="12" />' );
		} else {
			data.push( '<img src="/images/top-arrow-' + type + '-tiny.png" alt="" width="27" height="12" />' );
			data.push( '<img src="/images/bottom-arrow-' + type + '-tiny.png" alt="" width="27" height="12" />' );
		}
	}
	// rank
	data.push( '<p class="rank">(rank ' + rank + ')</p>' );
	// links list
	data.push( "<ul>");
	for ( i = 0; i < links.length; i++ ) {
		if (i>5) { break; }
		factor = i / links.length;
		res_rgb = get_color_related_index( color, factor );
		data.push( '<li><a href="' + links[i].url + '" style="color:rgb(' + res_rgb[0] + ',' + res_rgb[1] + ',' + res_rgb[2] + ');">' + links[i].text + "</a></li>");
	}
	data.push( "</ul>");
	return data.join("");
}

function get_color_related_index ( color, factor ) {
	return [
		Math.floor(color[0] - ( factor * (color[0] - COLOR_BLACK[0]) )),
		Math.floor(color[1] - ( factor * (color[1] - COLOR_BLACK[1]) )),
		Math.floor(color[2] - ( factor * (color[2] - COLOR_BLACK[2]) ))
	];
}

function show_resultlist( elem, resp, color ) {
	var height, tag_class = get_tag_class( elem, "id", "list" );
	elem.fadeOut(function() {
		var idx, tag, factor, res_size, res_rgb, li;
		elem.empty();
		for(idx=0;idx<resp.result.length;idx++){
			tag = resp.result[idx][0];
			factor = ((idx + 0) / resp.result.length);
			res_size = TEXTSIZE_MAX - ( factor * (TEXTSIZE_MAX - TEXTSIZE_MIN));
			res_rgb = get_color_related_index( color, factor );
			// create li element
			li = $('<li>' +
				'<a href="#" style="'+
				'font-size: '+res_size+'em; '+
				'color: rgb(' + res_rgb[0] + ',' + res_rgb[1] + ',' + res_rgb[2] + ');'+
				'">' + tag + '</a>' +
				'</li>');
			// add data
			li.data({
				tag: tag,
				links: resp.result[idx][1].links
			});
			// attach fancybox
			attach_fancybox( li, tag_class, res_rgb );
			// append to list
			li.appendTo( elem );
		}
		height = elem.height();
	}).fadeIn("fast", function() {
		elem.parent().animate({height: Math.min(TAG_LIST_MAX_HEIGHT, height) + "px"}, function () {
			$(this).jScrollPane({
				showArrows: true,
				arrowUp: $(".col_header > .tag_" + tag_class + " > div.arrow"),
				arrowDown: $(".col_footer > .tag_" + tag_class + " > div.arrow")
			});
		});
	});
}

function load_expected( query ) {
	$.ajax({
		url: "/search/expected?query=" + query,
		context: $('#list_expected'),
		dataType: 'json',
		timeout: AJAX_TIMEOUT,
		success: function( resp ){
			show_resultlist( $(this), resp, COLOR_EXPECTED );
		},
		error: function( req, error ) {
			setTimeout(function(){ load_expected(query); },2000);
		}
	});
}

function load_controversial( query ) {
	$.ajax({
		url: "/search/controversial?query=" + query,
		context: $('#list_controversial'),
		dataType: 'json',
		timeout: AJAX_TIMEOUT,
		success: function( resp ){
			show_resultlist( $(this), resp, COLOR_CONTROVERSIAL );
		},
		error: function( req, error ) {
			setTimeout(function(){ load_controversial(query); }, 2000);
		}
	});
}

function load_aggregating( query ) {
	$.ajax({
		url: "/search/aggregating?query=" + query,
		context: $('#list_aggregating'),
		dataType: 'json',
		timeout: AJAX_TIMEOUT,
		success: function( resp ){
			show_resultlist( $(this), resp, COLOR_AGGREGATING );
		},
		error: function( req, error ) {
			setTimeout(function(){ load_aggregating(query); }, 2000);
		}
	});
}

function get_tag_class ( element, attribute, prefix ) {
	var attribute = attribute || "class",
		prefix = prefix || "tag",
		re = new RegExp(prefix + "_([a-z]+)"),
		res;
	res = re.exec( $(element).attr( attribute ) );
	return res[1];
}

$(document).ready(function() {
	/* set focus */
	$('#searchwidget_query').focus();

	/* run queries */
	query = $('#searchwidget_oldquery').val();

	load_expected( query );
	load_controversial( query );
	load_aggregating( query );

	$("div.col_header h2").click(function(event){
		event.preventDefault();
		$(this).toggleClass("reverse");
		reverse_list( this );
	});
});
