class GamesController < ApplicationController
  def show
    @game = Game.new
    @map = [
        [ 0, 1, 1, 0, 1, 0, 0, 1 ],
        [ 0, 0, 0, 0, 1, 0, 0, 1 ],
        [ 0, 0, 0, 0, 1, 0, 0, 0 ],
        [ 0, 0, 1, 1, 1, 1, 0, 0 ],
        [ 0, 0, 0, 0, 0, 0, 0, 0 ],
        [ 0, 0, 1, 1, 1, 0, 0, 0 ],
        [ 0, 0, 0, 0, 1, 0, 0, 0 ],
        [ 0, 0, 0, 0, 1, 0, 0, 0 ],
      ]
  end

  def create
    moves = {
      moves: [
        { player: 0, x: 0, y: 0, result: 0 },
        { player: 1, x: 5, y: 5, result: 1 },
        { player: 1, x: 5, y: 6, result: 0 }
      ]
    }

    render json: moves
  end
end
