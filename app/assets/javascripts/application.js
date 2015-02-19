// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).on("ajax:success", function(event, response) {
  drawMoves(response["moves"]);
})

var drawMoves = function(data) {
  for(var i=0; i<data.length; i++) {
    var move = data[i]
    drawMove(move);
  }
}

var drawMove = function(move) {
  var player = move["player"];
  var x = move["x"];
  var y = move["y"];
  var result = move["result"];
  var cell = getCell(player, x, y);

  $(cell).addClass("result-"+result);
}

var drawMap = function(player, data) {
  for(var i=0; i<8; i++) {
    for(var j=0; j<8; j++) {
      cell = getCell(player, i, j)
      value = data[i][j];
      if(value === 1) $(cell).addClass("ship");
    }
  }
}

var getCell = function(player, x, y) {
  var selector = "player-" + player;
  return document.getElementById(selector).rows[y].cells[x];
}
