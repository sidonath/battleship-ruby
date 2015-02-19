BOT = <<-'BOT'
class Player
  def player_turn(map)

    loop do
      @x = rand(8)
      @y = rand(8)
      break unless map.visited?(@x, @y)
    end

    map.fire!(@x, @y)
  end
end
BOT

MAP = [
    [ 0, 1, 1, 0, 1, 0, 0, 1 ],
    [ 0, 0, 0, 0, 1, 0, 0, 1 ],
    [ 0, 0, 0, 0, 1, 0, 0, 0 ],
    [ 0, 0, 1, 1, 1, 1, 0, 0 ],
    [ 0, 0, 0, 0, 0, 0, 0, 0 ],
    [ 0, 0, 1, 1, 1, 0, 0, 0 ],
    [ 0, 0, 0, 0, 1, 0, 0, 0 ],
    [ 0, 0, 0, 0, 1, 0, 0, 0 ],
  ]

class GamesController < ApplicationController
  def show
    @game = Game.new
    @map = MAP
  end

  def create
    gr = GameRunner.new(params[:game][:code], BOT, MAP)
    moves = gr.()
    render json: { map: MAP, moves: moves.flatten }
  rescue RuntimeError => e
    render json: { error: e.to_s }
  end
end
