require 'delegate'

$MAP = [
  [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
  [1, 0, 0, 1, 0, 1, 0, 0, 0, 0],
  [1, 0, 0, 1, 0, 1, 0, 0, 0, 0],
  [1, 0, 0, 0, 0, 0, 0, 1, 0, 0],
  [1, 0, 0, 0, 0, 1, 0, 0, 0, 0],
  [0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
  [0, 1, 1, 1, 0, 0, 0, 1, 0, 0],
  [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
  [0, 0, 1, 1, 1, 0, 1, 1, 0, 0],
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
]

Shot = Struct.new(:x, :y, :hit)

class Map
  TILE_SEA    = 0
  TILE_SHIP   = 1
  TILE_WRACK  = 2

  def initialize
    # hack for deep clone of an array:
    @map = Marshal.load(Marshal.dump($MAP))
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

class PlayerSmarter
  def player_turn(map)

    loop do
      @x = rand(10)
      @y = rand(10)
      break if !map.visited?(@x, @y)
    end

    map.fire!(@x, @y)
  end
end

class PlayerDummy
  def player_turn(map)
    map.fire!(rand(10), rand(10))
  end
end

class PlayerDecorator < SimpleDelegator
  attr_reader :player_index

  def initialize(player_index, *args)
    @player_index = player_index
    super(*args)
  end
end

class Game < Struct.new(:player1, :player2, :map1, :map2)
  def initialize(player1, player2, map1, map2)
    super(PlayerDecorator.new(0, player1), PlayerDecorator.new(1, player2), map1, map2)
    @turn = 0
  end

  def run
    loop do
      @turn += 1

      status = catch :end do
        run_player(player1, map2)
        run_player(player2, map1)
      end

      break if @turn > 200 || status == :win
    end
  end

  private

  def run_player(player, opponent_map)
    loop do
      mi = MapInterface.new(opponent_map)
      player.player_turn(mi)

      x, y = mi.last_shot
      puts "#{player.player_index} #{x} #{y} #{mi.was_hit ? 1 : 0}"

      throw :end, :win if opponent_map.end?
      break unless mi.was_hit
    end
  end
end

g = Game.new(PlayerSmarter.new, PlayerDummy.new, Map.new, Map.new)
g.run
