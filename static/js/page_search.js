
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
		case "tag_expected" :
			_expected.reverse();
			ul = $("#list_expected");
			break;
		case "tag_controversial" :
			_controversial.reverse();
			ul = $("#list_controversial");
			break;
		case "tag_aggregating" :
			_aggregating.reverse();
			ul = $("#list_aggregating");
			break;
		default :
			return;
			break;
	}
	ul.fadeOut("normal", function () {
		lis = $.makeArray( ul.find("li") );
		ul.empty();
		lis.reverse();
		$(lis).appendTo( ul );
		$(this).fadeIn("slow");
	});
}

function show_resultlist( elem, resp, color ) {
	elem.fadeOut(function() {
		elem.empty();
		for(var idx=0;idx<resp.result.length;idx++){
			var tag = resp.result[idx][0];
			var factor = ((idx + 0) / resp.result.length);
			var res_size = TEXTSIZE_MAX - ( factor * (TEXTSIZE_MAX - TEXTSIZE_MIN));
			var res_rgb = [
				Math.floor(color[0] - ( factor * (color[0] - COLOR_BLACK[0]) )),
				Math.floor(color[1] - ( factor * (color[1] - COLOR_BLACK[1]) )),
				Math.floor(color[2] - ( factor * (color[2] - COLOR_BLACK[2]) ))
			];
			elem.append('<li>' +
				'<a href="#" style="'+
				'font-size: '+res_size+'em; '+
				'color: rgb(' + res_rgb[0] + ',' + res_rgb[1] + ',' + res_rgb[2] + ');'+
				'">' + tag + '</a>' +
				'</li>');
		}
		// make change happen
		elem.fadeIn();
		elem.data("tagListHeight", elem.height());
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

function get_tag_class ( element ) {
	var re = new RegExp("tag_[a-z]+"), res;
	res = re.exec( $(element).attr("class") );
	return res[0];
}

function move_list ( element, delta, tag_class_element ) {
	var tag_class = get_tag_class( tag_class_element || element ), ul, divListHeight, tagListPos, tagListHeight;
	ul = $("div." + tag_class + " > ul.taglist");
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
		$(this).data("tagListPos", 0);
		$(this).data("divListHeight", $(this).parent().height());
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
