code_template = <<-'CODE_TEMPLATE'
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
        puts "EXCEEDED LIMIT"
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
class Player
  def player_turn(map)

    loop do
      @x = rand(10)
      @y = rand(10)
      break unless map.visited?(@x, @y)
    end

    map.fire!(@x, @y)
  end
end
PLAYER_CODE

map = <<-MAP
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
MAP

require 'sicuro'
require 'erb'

erb = ERB.new(code_template, nil, "<>")
code = erb.result binding

r = Sicuro.eval(code)
if r.stderr.empty?
  puts r.stdout
else
  puts "Error!"
  puts r.stderr
end
