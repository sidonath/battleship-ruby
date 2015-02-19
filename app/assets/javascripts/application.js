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
    var moves = response["moves"];
    var map = response["map"];
    drawMoves(moves, map);
    drawWinner(moves[moves.length-1]);
  }
})

var drawWinner = function(lastMove) {
  var player = lastMove["player"];
  var result = lastMove["result"];
  if (result == 1) {
    alert("Player " + player + " wins!");
  }
  else {
    alert("Draw!");
  }
}

var drawMoves = function(moves, map) {
  drawMap(0, map);
  drawMap(1, map);

  for(var i=0; i<moves.length; i++) {
    var move = moves[i]
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
