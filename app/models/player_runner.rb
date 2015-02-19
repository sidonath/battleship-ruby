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

  def size
    @map.length
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
    if x < 0 || y < 0
      raise ArgumentError, "x and y coordinates should be greater than 0 (x: #{x}, y: #{y})."
    end
    if x >= @map.size || y >= @map.size
      raise ArgumentError, "x and y coordinates should be less than #{@map.size} (x: #{x}, y: #{y})."
    end

    if @turn_done
      raise "You can call fire! only once per turn!"
    end

    @turn_done = true
    @last_shot = [x, y]
    @was_hit = @map.fire!(x, y)
  end

  def visited?(x, y)
    @map.shots.any? { |s| s.x == x && s.y == y }
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

      begin
        @player.player_turn(map_interface)
      rescue StandardError => err
        raise InvalidAction, "[Turn #{@turn_no}]: #{err.message}"
      end

      x, y = map_interface.last_shot

      if x.nil? || y.nil?
        raise NoAction, "[Turn #{@turn_no}]: No action was called."
      end

      puts "#{x} #{y} #{map_interface.was_hit ? 1 : 0}"

      if @turn_no >= 200
        break
      end

      break if @map.end?
    end
  end

  class NoAction < RuntimeError; end
  class InvalidAction < RuntimeError; end
end

<%= player_class %>

map = <%= map %>

e = Engine.new(Player.new, Map.new(map))
e.run
CODE_TEMPLATE

class PlayerRunner < Struct.new(:player_class, :map)
  def call
    erb = ERB.new(CODE_TEMPLATE, nil, "<>")
    code = erb.result binding

    Rails.logger.info("[PlayerRunner] Running code..")
    Rails.logger.info(code)
    Rails.logger.info()

    syntax_check = Sicuro.eval(player_class)
    if syntax_check.stderr.present?
      raise SyntaxError, syntax_check.stderr
    end

    r = Sicuro.eval(code)
    if r.stderr.empty?
      return r.stdout.split("\n").map { |s| s.split.map(&:to_i) }
    else
      raise Error, r.stderr
    end
  end

  class Error < RuntimeError; end
  class SyntaxError < RuntimeError; end
end
