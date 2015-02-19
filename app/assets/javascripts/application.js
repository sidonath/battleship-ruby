//= require jquery
//= require jquery_ujs
//= require ace/ace
//= require ace/worker-html
//= require ace/mode-ruby
//= require ace/theme-solarized_dark
//= require bootstrap-sprockets
//= require_tree .

$(document).on("ajax:success", function(event, response) {
  if (response['error']) {
    alert(response['error']);
  } else {
    drawMoves(response["moves"], response["map"]);
  }
})

var DRAW_INTERVAL = 100;
var playerStats;


var initPlayerStats = function() {
  playerStats = { 
    0 : { hits : 0, moves : 0 },
    1 : { hits : 0, moves : 0 }
  };
}

var drawPlayerStats = function(player, stat) {
  $('#player-' + player + ' span').html("MOVES : " + stat.moves + " HITS : " + stat.hits);
}

var updatePlayerStats = function(move) {
  playerStats[move["player"]].hits += move["result"];
  playerStats[move["player"]].moves ++;
}

var drawMoves = function(moves, map) {
  drawMap(0, map);
  drawMap(1, map);
  initPlayerStats();

  for(var i=0; i<moves.length; i++) {
    var move = moves[i];
    drawMove(move, i);
  }
  setTimeout(function() {
    drawWinner(moves[moves.length-1]);
  }, DRAW_INTERVAL * (i+1));
}

var drawWinner = function(lastMove) {
  var player = lastMove["player"];
  var result = lastMove["result"];
  if (result == 1) {
    alert("Player " + (player+1) + " wins!");
  }
  else {
    alert("Draw!");
  }
}


var drawMove = function(move, index) {
  setTimeout(function() {
    var player = move["player"];
    var x = move["x"];
    var y = move["y"];
    var result = move["result"];
    var cell = getCell(player, x, y);

    updatePlayerStats(move);
    drawPlayerStats(player, playerStats[player]);

    $(cell).addClass("result-"+result);
  }, DRAW_INTERVAL * index);
}

var drawMap = function(player, map) {
  for(var i=0; i<8; i++) {
    for(var j=0; j<8; j++) {
      cell = getCell(player, i, j)
      value = map[j][i];
      $(cell).removeClass();
      if(value === 1) $(cell).addClass("ship");
    }
  }
}

var getCell = function(player, x, y) {
  var selector = "player-" + player;
  return document.getElementById(selector).rows[y].cells[x];
}

if ($('#editor').length) {
  var RubyMode = require('ace/mode/ruby').Mode;

  var editor = ace.edit('editor');
  var textarea = $('.code-textarea');

  $('#editor').css({ fontSize: '16px' })
  editor.getSession().setMode(new RubyMode());
  editor.setTheme('ace/theme/solarized_dark');

  editor.getSession().setTabSize(2);
  editor.getSession().setUseSoftTabs(true);

  editor.setValue(textarea.val());
  editor.getSession().on('change', function () {
    textarea.val(editor.getValue());
  });
  textarea.closest('form').on('submit', function () {
    textarea.val(editor.getValue());
  });

  editor.commands.addCommand({
    name: 'submitCommand',
    bindKey: {win: 'Ctrl-Enter',  mac: 'Command-Enter'},
    exec: function(editor) {
      textarea.closest('form').submit();
    }
  });

  editor.gotoLine(3);
}
