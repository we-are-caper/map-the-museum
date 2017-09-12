$(function() {


	$("#map").css({height: $(window).height() + "px"});

	$(window).bind("resize", function() {
		$("#map").css({height: $(window).height() + "px"});
		resizeMap();
	});

	$(window).load(function(){
		$("#map").css({height: $(window).height() + "px"});
	});

	$("#main").on("click", "#i_know", function() {
		i_know_where_it_goes();
	}).on("tap", "#i_know", function() {
		i_know_where_it_goes();
	});

	function i_know_where_it_goes() {
		$("#i_know").fadeOut();
		$("#challenge").fadeOut();
		$("#main").fadeOut(); //RJ
		$("#placing h2 #object_name").text($("#challenge #todo_object_name a").text());
		$("#thanks_object_name").text($("#challenge #todo_object_name a").text());
		$("#todo").addClass("working");
		$("#here").show();
		$("#place_it_here").show();
		$("#placing").fadeIn();
		$("#reason").remove();
		positionMarker();
		if ( $("#i_know").attr('data-flag') == "disputed" ) {
			$("#instructions").after('<div id="reason"><h3>Reason for disputing location</h3><input name="reason" type="text" id="reason_text" placeholder="I am disputing it because..." /></div>');
		}
	}

	$("#get_started").click(function() {
		get_started();
	}).bind("tap",function() {
		get_started();
	});

	function get_started() {
		$("#logo").fadeIn();
		loadTodo();
	}

	$(".no_thanks").click(function() {
		no_thanks();
	}).bind("tap",function() {
		no_thanks();
	});

	function no_thanks(){
		$("#logo").fadeIn();
		$("#thanks").fadeOut();
		$("#intro").fadeOut();
		$("#stop_exploring").fadeIn();
	}

	$("#stop_exploring .button, #show_map").click(function() {
		stop_exploring();
		$("#main").fadeIn(); //RJ
	}).bind("tap",function() {
		stop_exploring();
	});

	function stop_exploring() {
		$("#stop_exploring").fadeOut();
		$("#intro").fadeIn();
		$("#logo").fadeOut();
		$("#thanks").fadeOut();
		$("#placing").fadeOut();
		$("#here").fadeOut();
	}

	$("#placing").on("click", "#give_up", function(){
		loadTodo();
	}).on("tap", "#give_up", function(){
		loadTodo();
	});

	$("#main").on("click", "#another", function(){
		loadTodo();
	}).on("tap", "#another", function(){
		loadTodo();
	});

	$("#try_again").click(function() {
		try_again();
	}).bind("tap",function() {
		try_again();
	});

	function try_again() {
		$("#thanks").hide();
		loadTodo();
	}

	window.setupItem = function(data) {
		$("#intro").hide();
		$(".fancybox").fancybox();
		$("#challenge")
			.hide()
			.removeClass("hidden")
			.empty()
			.append(data)
			.fadeIn();

		$("#placing").hide();
		$("#here").hide();
		$("#stop_exploring").fadeOut();
		$("#i_know").show();
		$("#another").show();

		$("#todo h2 a").click(function() {
			$("#i_know").fadeIn();
			$("#placing").fadeOut();
		});
		setTimeout("setupSuggestedLocations()",200);

		if (window.starting_hash[3]) {
			$("#i_know").text('Check item location');
		}
	};

	window.loadTodo = function() {
		$("#intro").fadeOut(function() {
			$.get("/items/todo?" + Math.floor((Math.random() * 100000)), function(data) {
				setupItem(data);
			});
		});
	};

	window.showItem = function(url) {
		$("#intro").fadeOut(function() {
			$.get(url, function(data) {
				setupItem(data);
			});
		});
	};

	window.setupSuggestedLocations = function() {
		$(".potential_location").tipTip();
		$(".potential_location").click(function() {
			$("#challenge").fadeOut();
			$("#i_know").fadeOut();
			$("#here").show();
			$("#placing").show();
			$.getJSON("/items/geolocate.json?address=" + $(this).data().match, function(data) {
				if(data.status == "success") {
					centerMap(data.lat, data.lng);
				}
			});
		});
	};

	window.placeItem = function() {
		var lat_lng = getMapCenter();
		var status = $('#i_know').attr('data-flag');
		var reason = $('#reason_text').val() ? $('#reason_text').val() : "It's here";
		$.ajax({
			url: $("#todo").data().url,
			type: "PUT",
			data: {
				lat: lat_lng.lat,
				lng: lat_lng.lng,
				reason: reason,
				status: status
			},
			success: function() {
				$("#challenge").hide();
				$("#thanks").fadeIn();
				$("#i_know").hide();
				$("#another").hide();
				$("#here").hide();
				$("#placing").hide();
				$("#main").fadeIn();
			}
		});
	};

	window.needsStreetviewUpdate = false;

	$(window).hashchange( function(){
		window.needsStreetviewUpdate = true;
	});

	var streetViewInterval = setInterval(function() {
		if(needsStreetviewUpdate) {
			needsStreetviewUpdate = false;
			var hashSplit = location.hash.split("/");
			$("#streetview img").attr("src", "http://cbk0.google.com/cbk?output=thumbnail&w=420&h=180&ll=" + hashSplit[1] + "," + hashSplit[2]);
			$("#streetview a").attr("href", "http://cbk0.google.com/cbk?output=thumbnail&w=420&h=240&ll=" + hashSplit[1] + "," + hashSplit[2]);
		}
	}, 500);

	$(".panner").mousemove(function(e) {
		var offset = $(this).offset();
	});

	$("#find_a_place form").submit(function(){
		$.get("/items/geolocate.json?address=" + $(this).find("input[type=text]").val(), function(data) {
			if(data.status == "success") {
				centerMap(data.lat, data.lng);
			}
			$("#find_a_place form input[type=text]").val("");
		});
		return(false);
	});

	$("#main").on("click", "#close", function() {
		$("#challenge").fadeOut();
		$("#stop_exploring").fadeIn();
	}).on("tap", "#close", function() {
		$("#challenge").fadeOut();
		$("#stop_exploring").fadeIn();
	});

	$("#place_it_here").click(function() {
		placeItem();
	}).bind("tap", function() {
		placeItem();
	});

	$("#submit_dispute").click(function() {
		placeItem();
	}).bind("tap", function() {
		placeItem();
	});

	$("#streetview a").fancybox();
	$("#here").removeClass("hidden").hide();
	$("#another").removeClass("hidden").hide();
	$("#i_know").removeClass("hidden").hide();
	$("#placing").removeClass("hidden").hide();
	$("#thanks").removeClass("hidden").hide();
	$("#logo").removeClass("hidden").hide();
	$("#stop_exploring").removeClass("hidden").hide();
	$("#not_ie_8_message").removeClass("hidden");

	if (window.starting_hash[3]) {
		$(document).ready(function(){
			// show the right item
			showItem("/items/"+window.starting_hash[3]);
			// move the map in the right place
			centerMap(window.starting_hash[1], window.starting_hash[2]);
			// display the marker in the right place
			$("#close").click(function(){
				alert('yo');
			});
		});
	}

});
