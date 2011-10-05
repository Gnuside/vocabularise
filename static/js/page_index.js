
$(document).ready(function() {
	$('#searchwidget_query').focus();
	$("#title").tooltip({
		bodyHandler: function () {
			return $("#tooltip_title").html();
		},
		extraClass: "tooltip_title",
		track: true
	});
});
