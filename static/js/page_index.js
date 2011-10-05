
$(document).ready(function() {
	$('#searchwidget_query').focus();
	$("#title").tooltip({
		bodyHandler: function () {
			return $("#tooltip_title").html();
		},
		track: true
	});
	$("li.tag_expected").tooltip({
		bodyHandler: function () {
			return $("#tooltip_expected").html();
		},
		extraClass: "tooltip_expected",
		track: true
	});
	$("li.tag_controversial").tooltip({
		bodyHandler: function () {
			return $("#tooltip_controversial").html();
		},
		extraClass: "tooltip_controversial",
		track: true
	});
	$("li.tag_aggregating").tooltip({
		bodyHandler: function () {
			return $("#tooltip_aggregating").html();
		},
		extraClass: "tooltip_aggregating",
		track: true
	});
});
