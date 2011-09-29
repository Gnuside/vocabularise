
var COLOR_EXPECTED = [ 60, 165, 43 ]; // #3ca52b
var COLOR_CONTROVERSIAL = [ 231, 80, 24 ]; // #e75018
var COLOR_AGGREGATING= [ 0, 139, 208 ]; // #008bd0
var COLOR_BLACK = [0,0,0];

var TEXTSIZE_MIN = 0.6;
var TEXTSIZE_MAX = 2;

var AJAX_TIMEOUT = 8000;

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
			elem.append('<li>'+
				'<a href="#" style="'+
				'font-size: '+res_size+'em; '+
				'color: rgb(' + res_rgb[0] + ',' + res_rgb[1] + ',' + res_rgb[2] + ');'+ 
				'">' + tag + '</a>' + 
				'</li>');
		}
		// make change happen
		elem.fadeIn();
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
			setTimeout(function(){ load_aggregating(query); }, 2000);
		}
	});
}

$(document).ready(function() {
	/* set focus */
	$('#searchwidget_query').focus();

	/* run queries */
	query = $('#searchwidget_oldquery').val();

	load_expected( query );
	load_controversial( query );
	load_aggregating( query );
});

