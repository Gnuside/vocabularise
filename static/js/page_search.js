
var COLOR_EXPECTED = [ 60, 165, 43 ]; // #3ca52b
var COLOR_CONTROVERSIAL = [ 231, 80, 24 ]; // #e75018
var COLOR_AGGREGATING= [ 0, 139, 208 ]; // #008bd0
var COLOR_BLACK = [0,0,0];

var TEXTSIZE_MIN = 0.6;
var TEXTSIZE_MAX = 2;

var AJAX_TIMEOUT = 8000;
var SLIDE_DELTA = 30;

var _expected, _controversial, _aggregating;

function reverse_list ( list_header ) {
	var tag_class = get_tag_class( $(list_header).parent("div.tag") ), ul, lis;
	switch ( tag_class ) {
		case "expected" :
			_expected.reverse();
			ul = $("#list_expected");
			break;
		case "controversial" :
			_controversial.reverse();
			ul = $("#list_controversial");
			break;
		case "aggregating" :
			_aggregating.reverse();
			ul = $("#list_aggregating");
			break;
		default :
			return;
			break;
	}
	ul.fadeOut("normal", function () {
		lis = ul.children("li").detach().get();
		lis.reverse();
		$(lis).appendTo( ul );
		$(this).fadeIn("slow");
	});
}

function attach_fancybox ( li, tag_class ) {
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
						get_links( curArr, tag, tag_class, "expected" ),
					'</div>',
					'<div class="tag_controversial span-8">',
						get_links( curArr, tag, tag_class, "controversial" ),
					'</div>',
					'<div class="tag_aggregating span-8 last">',
						get_links( curArr, tag, tag_class, "aggregating" ),
					'</div>',
				'</div>'
			];
			$("#tag_details").html( data.join("") );
			$.fancybox.resize();
			$("#fancybox-wrap").animate({
				width: 970,
				//left: 320
				top: parseInt(Math.max(view[3] - 20, view[3] + ((view[1] - $("#fancybox-content").height() - 40) * 0.5) - curOpts.padding)), // @see fancybox center
				left: parseInt(Math.max(view[2] - 20, view[2] + ((view[0] - 950 - 40) * 0.5) - curOpts.padding)) // @see fancybox center
			}, {
				duration: "fast",
				step: function ( now, fx ) {
					if ( "width" === fx.prop ) {
						var left = $("#fancybox-wrap").css( "left" );
						$("#fancybox-content").width( now - 20 );
					}
				},
				complete: function () {
					//$.fancybox.center();
				}
			});
		}
	});
}

function show_resultlist( elem, resp, color ) {
	elem.fadeOut(function() {
		var idx, tag, factor, res_size, res_rgb, li, tag_class = get_tag_class( elem, "id", "list" );
		elem.empty();
		for(idx=0;idx<resp.result.length;idx++){
			tag = resp.result[idx][0];
			factor = ((idx + 0) / resp.result.length);
			res_size = TEXTSIZE_MAX - ( factor * (TEXTSIZE_MAX - TEXTSIZE_MIN));
			res_rgb = [
				Math.floor(color[0] - ( factor * (color[0] - COLOR_BLACK[0]) )),
				Math.floor(color[1] - ( factor * (color[1] - COLOR_BLACK[1]) )),
				Math.floor(color[2] - ( factor * (color[2] - COLOR_BLACK[2]) ))
			];
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
			attach_fancybox( li, tag_class );
			// append to list
			li.appendTo( elem );
		}
		// make change happen
		elem.fadeIn();
		elem.data("tagListHeight", elem.height());
	});
}

function get_links ( liElement, tag, tag_class, type ) {
	// TODO
	return [];
}

function load_expected( query ) {
	$.ajax({
		url: "/search/expected?query=" + query,
		context: $('#list_expected'),
		dataType: 'json',
		timeout: AJAX_TIMEOUT,
		success: function( resp ){
			show_resultlist( $(this), resp, COLOR_EXPECTED );
			_expected = resp.result;
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
			_controversial = resp.result;
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
			_aggregating = resp.result;
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

function move_list ( element, delta, tag_class_element ) {
	var tag_class = get_tag_class( tag_class_element || element ), ul, divListHeight, tagListPos, tagListHeight;
	ul = $("div.tag_" + tag_class + " > ul.taglist");
	tagListPos = ul.data("tagListPos");
	divListHeight = ul.data("divListHeight");
	tagListHeight = ul.data("tagListHeight");
	// stop scroll when first or last element already shown
	if ( 0 === tagListPos && 0 > delta ) {
		return;
	} else if ( (tagListHeight + tagListPos < divListHeight) && 0 < delta ) {
		return;
	}
	tagListPos -= delta;
	ul.animate(
		{ top: tagListPos + "px" }, "normal"
	);
	ul.data("tagListPos", tagListPos);
}

function move_list_up ( element ) {
	move_list( element, -SLIDE_DELTA, $(element).parent("div.tag") );
}

function move_list_down ( element ) {
	move_list( element, SLIDE_DELTA, $(element).parent("div.tag") );
}

$(document).ready(function() {
	/* set focus */
	$('#searchwidget_query').focus();

	/* run queries */
	query = $('#searchwidget_oldquery').val();

	load_expected( query );
	load_controversial( query );
	load_aggregating( query );

	$("ul.taglist").each(function (){
		$(this).data({
			tagListPos: 0,
			divListHeight: $(this).parent().height()
		});
	});
	$("img.top_arrow").click(function(event){
		event.preventDefault();
		move_list_up( this );
	});
	$("img.bottom_arrow").click(function(event){
		event.preventDefault();
		move_list_down( this );
	});
	$("div.col_content div").mousewheel(function(event, delta){
		event.preventDefault();
		if (delta > 0) {
			move_list( this, -SLIDE_DELTA );
		} else {
			move_list( this, SLIDE_DELTA );
		}
	});
	$("div.col_header h2").click(function(event){
		event.preventDefault();
		$(this).toggleClass("reverse");
		reverse_list( this );
	});
});
