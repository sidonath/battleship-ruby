class GameRunner < Struct.new(:player_1_class, :player_2_class, :map)
  def call
    player_1_results = wrap_exception("First player") { PlayerRunner.new(player_1_class, map).() }
    player_2_results = wrap_exception("Second player") { PlayerRunner.new(player_2_class, map).() }

    moves = []

    loop do
      p1_last_shot_index = player_1_results.find_index { |(x, y, result)| result == 0 }
      p2_last_shot_index = player_2_results.find_index { |(x, y, result)| result == 0 }

      if p1_last_shot_index
        p1_moves = player_1_results[0..p1_last_shot_index].map { |(x, y, result)| { player: 0, x: x, y: y, result: result } }
      else
        p1_moves = player_1_results.map { |(x, y, result)| { player: 0, x: x, y: y, result: result } }
      end

      if p2_last_shot_index
        p2_moves = player_2_results[0..p2_last_shot_index].map { |(x, y, result)| { player: 1, x: x, y: y, result: result } }
      else
        p2_moves = player_2_results.map { |(x, y, result)| { player: 1, x: x, y: y, result: result } }
      end

      if p1_last_shot_index || p1_moves[2] == 0
        moves << p1_moves + p2_moves
      else
        moves << p1_moves
      end

      break if !p1_last_shot_index || !p2_last_shot_index

      player_1_results = player_1_results[p1_last_shot_index+1..-1]
      player_2_results = player_2_results[p2_last_shot_index+1..-1]

      break if player_1_results.empty? || player_2_results.empty?
    end

    moves
  end

  def wrap_exception(player_name, &blk)
    yield
  rescue PlayerRunner::SyntaxError => err
    raise Error, err.message.lines[0]
  rescue PlayerRunner::Error => err
    raise Error, "#{player_name}'s code raised an exception:\n#{err.message.lines[0]}"
  end

  class Error < RuntimeError
  end
end
