STARTING_POINT = <<-'STARTING_POINT'
class Player
  def player_turn(map)
    # Vaš Ruby kôd ide ovdje. Sretno potapanje!
  end
end
STARTING_POINT

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
    code =
      if current_user.code.present?
        current_user.code
      else
        STARTING_POINT
      end

    @game = Game.new(code: code)
    @map = MAP
  end

  def create
    code = params[:game][:code]
    current_user.update!(code: code)

    gr = GameRunner.new(params[:game][:code], BOT, MAP)
    moves = gr.()
    render json: { map: MAP, moves: moves.flatten }
  rescue RuntimeError => e
    render json: { error: e.to_s }
  end
end
