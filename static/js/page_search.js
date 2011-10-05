
var COLOR_EXPECTED = [ 60, 165, 43 ]; // #3ca52b
var COLOR_CONTROVERSIAL = [ 231, 80, 24 ]; // #e75018
var COLOR_AGGREGATING= [ 0, 139, 208 ]; // #008bd0
var COLOR_BLACK = [0,0,0];

var TEXTSIZE_MIN = 0.6;
var TEXTSIZE_MAX = 2;

var AJAX_TIMEOUT = 8000;
var SLIDE_DELTA = 30;

function show_resultlist( elem, resp, color ) {
	//alert("got "+result);

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
		success: function( resp ){ show_resultlist( $(this), resp, COLOR_EXPECTED ); },
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
		success: function( resp ){ show_resultlist( $(this), resp, COLOR_CONTROVERSIAL ); },
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
		success: function( resp ){ show_resultlist( $(this), resp, COLOR_AGGREGATING ); },
		error: function( req, error ) {
			setTimeout(function(){ load_aggregating(query); }, 2000);
		}
	});
}

function move_list ( element, delta ) {
	var classes = $(element).attr("class"), tag_class,
		re = new RegExp("tag_[a-z]+"), ul, divListHeight, tagListPos, tagListHeight;
	tag_class = re.exec( classes );
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
	move_list( element, -SLIDE_DELTA );
}

function move_list_down ( element ) {
	move_list( element, SLIDE_DELTA );
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
		if (delta > 0) {
			move_list_up( this );
		} else {
			move_list_down( this );
		}
	});
});
