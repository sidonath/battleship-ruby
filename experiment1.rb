CODE_TEMPLATE = <<-'CODE_TEMPLATE'
Shot = Struct.new(:x, :y, :hit)

class Map
  TILE_SEA    = 0
  TILE_SHIP   = 1
  TILE_WRACK  = 2

  def initialize(map)
    # hack for deep clone of an array:
    @map = Marshal.load(Marshal.dump(map))
    @shots = []
  end

  def dump
    @map.to_a.each {|r| puts r.inspect }
  end

  def fire!(x, y)
    hit = @map[y][x] == TILE_SHIP
    @map[y][x] = TILE_WRACK if hit
    @shots << Shot.new(x, y, hit)
    return hit
  end

  def shots
    return @shots
  end

  def end?
    return @map.flatten.index(TILE_SHIP).nil?
  end
end

class MapInterface
  attr_reader :was_hit, :last_shot

  def initialize(map)
    @map = map
    @turn_done = false
    @was_hit = false
  end

  def fire!(x, y)
    if @turn_done
      raise "You can call fire! only once per turn!"
    end

    @turn_done = true
    @last_shot = [x, y]
    @was_hit = @map.fire!(x, y)
  end

  # TODO Ovo je pravo zno-ru
  def visited?(x, y)
    return !@map.shots.find { |s| s.x == x && s.y == y }.nil?
  end
end

class Engine
  def initialize(player, map)
    @map = map
    @player = player
    @turn_no = 0
  end

  def run
    @turn_no = 0

    loop do
      @turn_no += 1
      map_interface = MapInterface.new(@map)

      @player.player_turn(map_interface)

      x, y = map_interface.last_shot
      puts "#{x} #{y} #{map_interface.was_hit ? 1 : 0}"

      if @turn_no >= 200
        break
      end

      break if @map.end?
    end
  end
end

<%= player_class %>

map = <%= map %>

e = Engine.new(Player.new, Map.new(map))
e.run
CODE_TEMPLATE

# class PlayerSmarter
#   def player_turn(map)
#
#     loop do
#       @x = rand(10)
#       @y = rand(10)
#       break unless map.visited?(@x, @y)
#     end
#
#     map.fire!(@x, @y)
#   end
# end
#
# class PlayerDummy
#   def player_turn(map)
#     map.fire!(rand(10), rand(10))
#   end
# end

player_class = <<-'PLAYER_CODE'
class PlayerSmarter
  def player_turn(map)

    loop do
      @x = rand(10)
      @y = rand(10)
      break unless map.visited?(@x, @y)
    end

    map.fire!(@x, @y)
  end
end

class PlayerDummy
  def player_turn(map)
    map.fire!(rand(10), rand(10))
  end
end

class PlayerWhoDoesntGetIt
  def player_turn(map)
    map.fire!(0, 0)
  end
end

Player = PlayerSmarter
PLAYER_CODE

map =
  [
    [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
    [1, 0, 0, 1, 0, 1, 0, 0, 0, 0],
    [1, 0, 0, 1, 0, 1, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 1, 0, 0],
    [1, 0, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 1, 1, 1, 0, 0, 0, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 1, 1, 1, 0, 1, 1, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ]

require 'sicuro'
require 'erb'

class PlayerRunner < Struct.new(:player_class, :map)
  def call
    erb = ERB.new(CODE_TEMPLATE, nil, "<>")
    code = erb.result binding

    r = Sicuro.eval(code)
    if r.stderr.empty?
      return r.stdout.split("\n")
    else
      raise RuntimeError, r.stderr
    end
  end
end

class GameRunner < Struct.new(:player_1_class, :player_2_class, :map)
  def call
    player_1_runner = PlayerRunner.new(player_1_class, map)
    player_2_runner = PlayerRunner.new(player_2_class, map)

    player_1_results = player_1_runner.().map { |s| s.split.map(&:to_i) }
    player_2_results = player_2_runner.().map { |s| s.split.map(&:to_i) }

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
end

# p PlayerRunner.new(player_class, map).()
p GameRunner.new(player_class, player_class, map).()
