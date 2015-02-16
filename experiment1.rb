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

  def initialize(map)
    @map = map
    @turn_done = false
  end

  def fire!(x, y)
    if !@turn_done
      @turn_done = true
      return @map.fire!(x, y)
    end    
    return false
  end

  # TODO Ovo je pravo zno-ru
  def visited?(x, y)
    return !@map.shots.find { |s| s.x == x && s.y == y }.nil?
  end
end


class Engine

  def initialize(player1)
    @map1 = Map.new
    @player1 = player1
    @turn_no = 0
  end

  def run
    @turn_no = 0
    while(!@map1.end?) do
      @turn_no += 1
      map_interface = MapInterface.new(@map1)

      point1 = @player1.player_turn(map_interface)
      puts "---[#{@turn_no}]----------------------"
      @map1.dump()
    end

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

e = Engine.new(PlayerSmarter.new)
e.run
