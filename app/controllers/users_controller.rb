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
      @x = rand(10)
      @y = rand(10)
      break unless map.visited?(@x, @y)
    end

    map.fire!(@x, @y)
  end
end
BOT

MAP = [
    [ 1, 1, 0, 1, 0, 0, 1, 1, 1, 1 ],
    [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 ],
    [ 1, 0, 0, 1, 0, 1, 1, 1, 0, 1 ],
    [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 ],
    [ 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
    [ 1, 0, 0, 0, 0, 1, 0, 0, 0, 1 ],
    [ 0, 0, 0, 0, 0, 1, 0, 0, 0, 1 ],
    [ 1, 1, 0, 0, 0, 0, 0, 0, 0, 1 ],
    [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],
    [ 0, 0, 0, 0, 1, 1, 1, 1, 1, 1 ]
  ]

class UsersController < ApplicationController
  def show
    if current_user.code.blank?
      current_user.update(code: STARTING_POINT)
    end

    @user = current_user
    @map = MAP
  end

  def update
    code = params[:user][:code]
    current_user.update!(code: code)

    gr = GameRunner.new(code, BOT, MAP)
    moves = gr.()
    render json: { map: MAP, moves: moves.flatten }
  rescue RuntimeError => e
    render json: { error: e.to_s }
  end
end
