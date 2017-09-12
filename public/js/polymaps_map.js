$(function() {
  window.starting_hash = location.hash.split("/");

  var po = org.polymaps;

  var svg = n$("#map").add("svg:svg");
  svg.attr('width', '100%');
  svg.attr('height', '100%');

  var color = pv.Scale.linear()
      .domain(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
      .range("#fff", "#eee", "#ddd", "#ccc", "#bbb", "#aaa", "#999", "#888", "#777", "#666", "#555");

  window.map = po.map()
      .container($n(svg))
      .add(po.interact())
      .add(po.hash());


  var mapbox_map_id = $('body').attr('mapbox_map_id');
  var mapbox_url = "https://{S}.tiles.mapbox.com/v3/" + mapbox_map_id + "/{Z}/{X}/{Y}.png";

  map.add(po.image()
    .url(po
        .url(mapbox_url)
        .hosts(["a", "b", "c"])));

  map.add(po.geoJson()
    .url("/geo?rand=" + Math.floor(Math.random()*1000000))
    .id("markers")
    .tile(false)
    .on("load", load)
  );

  map.add(po.compass()
    .pan("none").position("bottom-right"));

  window.centerMap = function(lat, lng) {
    map.center({lat: lat, lon: lng}).zoom(16);
  }

  window.getMapCenter = function() {
    var hashSplit = location.hash.split("/");
    var result = {
      lat: hashSplit[1],
      lng: hashSplit[2].replace("#","")
    }
    return(result);
  }

  window.resizeMap = function() {
    map.resize();
    positionMarker();
  }

  window.positionMarker = function() {
    var location = map.locationPoint(map.center());
    $("#here").css({top: location.y + "px", left: location.x + "px"})
  }

  $(window).hashchange(function() {
    positionMarker();
  });

  function load(e) {
    for (var i = 0; i < e.features.length; i++) {
      var c = n$(e.features[i].element),
          g = c.parent();

      var image = g.add("svg:image")
        .attr("xlink:href", e.features[i].data.properties.thumbnail)
        .attr("width", "50")
        .attr("height", "50")
        .attr("title", e.features[i].data.properties.url)
        .attr("transform", c.attr("transform"));
      var url = e.features[i].data.properties.url;
      $(image.element).bind("click", function(){
        if($("#placing:visible").length == 0) {
          showItem($(this).attr("title"));
        }
      });
    }
  }

  if(starting_hash.length == 3) {
    map.center({
      lat: parseFloat(starting_hash[1]),
      lon: parseFloat(starting_hash[2])
    }).zoom(parseFloat(starting_hash[0].replace("#","")));
  }
  else {
    map.center({lat: 50.83, lon: -0.14}).zoom(14);
  }
  map.resize();

});
